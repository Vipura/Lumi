import 'dart:convert';
import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/lumi_database.dart';
import '../../data/repositories/attachments_repository.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';

final attachmentServiceProvider = Provider<LumiAttachmentService>(
  (ref) => LumiAttachmentService(ref.watch(attachmentsRepositoryProvider)),
);

/// Pure-isolate thumbnail generator so large photos resize off the UI thread.
Uint8List? _encodeThumbnailBytes(Uint8List sourceBytes) {
  final decoded = img.decodeImage(sourceBytes);
  if (decoded == null) return null;
  final resized = decoded.width > 360 || decoded.height > 360
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? 360 : null,
          height: decoded.height > decoded.width ? 360 : null,
        )
      : decoded;
  return Uint8List.fromList(img.encodeJpg(resized, quality: 82));
}

class LumiAttachmentService {
  LumiAttachmentService(this._repo);

  final AttachmentsRepository _repo;
  final ImagePicker _imagePicker = ImagePicker();
  static const _uuid = Uuid();

  Future<String> ensureAttachmentsDir() async {
    if (kIsWeb) return 'web_memory';
    final docs = await getApplicationDocumentsDirectory();
    final dir = io.Directory(p.join(docs.path, 'lumi_attachments'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<Attachment?> pickAndAttachImage({
    required String itemId,
    required ImageSource source,
  }) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    final thumbBytes = await compute(_encodeThumbnailBytes, bytes);

    if (kIsWeb) {
      final dataUrl =
          'data:image/jpeg;base64,${base64Encode(thumbBytes ?? bytes)}';
      return _repo.addAttachment(
        itemId: itemId,
        kind: LumiAttachmentKind.image,
        path: dataUrl,
        name: picked.name,
        sizeBytes: bytes.length,
        metadata: {'thumbDataUrl': dataUrl},
      );
    }

    final dir = await ensureAttachmentsDir();
    final id = _uuid.v4();
    final ext = p.extension(picked.name).isEmpty
        ? '.jpg'
        : p.extension(picked.name);
    final targetPath = p.join(dir, '$id$ext');
    await io.File(targetPath).writeAsBytes(bytes);

    String? thumbPath;
    if (thumbBytes != null) {
      thumbPath = p.join(dir, '${id}_thumb.jpg');
      await io.File(thumbPath).writeAsBytes(thumbBytes);
    }

    return _repo.addAttachment(
      itemId: itemId,
      kind: LumiAttachmentKind.image,
      path: targetPath,
      name: picked.name,
      sizeBytes: bytes.length,
      metadata: {'thumbPath': ?thumbPath},
    );
  }

  Future<Attachment?> pickAndAttachFile({required String itemId}) async {
    final file = await FilePicker.pickFile();
    if (file == null) return null;
    final ext = p.extension(file.name).toLowerCase();
    final kind = ext == '.pdf'
        ? LumiAttachmentKind.pdf
        : (const ['.png', '.jpg', '.jpeg', '.webp', '.heic'].contains(ext))
        ? LumiAttachmentKind.image
        : LumiAttachmentKind.file;

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      final size = await file.length() ?? bytes.length;
      final encoded = base64Encode(bytes);
      final mime = kind == LumiAttachmentKind.pdf
          ? 'application/pdf'
          : 'application/octet-stream';
      return _repo.addAttachment(
        itemId: itemId,
        kind: kind,
        path: 'data:$mime;base64,$encoded',
        name: file.name,
        sizeBytes: size,
      );
    }

    final srcPath = file.path;
    if (srcPath == null) return null;
    final dir = await ensureAttachmentsDir();
    final targetPath = p.join(dir, '${_uuid.v4()}_${file.name}');
    final copied = await io.File(srcPath).copy(targetPath);
    final size = await copied.length();

    String? thumbPath;
    if (kind == LumiAttachmentKind.image) {
      final bytes = await copied.readAsBytes();
      final thumbBytes = await compute(_encodeThumbnailBytes, bytes);
      if (thumbBytes != null) {
        thumbPath = p.join(dir, '${_uuid.v4()}_thumb.jpg');
        await io.File(thumbPath).writeAsBytes(thumbBytes);
      }
    }

    return _repo.addAttachment(
      itemId: itemId,
      kind: kind,
      path: copied.path,
      name: file.name,
      sizeBytes: size,
      metadata: {'thumbPath': ?thumbPath},
    );
  }

  Future<Attachment> saveRecordedAudio({
    required String itemId,
    required String sourcePath,
    required int durationMs,
  }) async {
    final fileName = 'Voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    if (kIsWeb) {
      return _repo.addAttachment(
        itemId: itemId,
        kind: LumiAttachmentKind.audio,
        path: sourcePath,
        name: fileName,
        durationMs: durationMs,
      );
    }

    final dir = await ensureAttachmentsDir();
    final targetPath = p.join(dir, '${_uuid.v4()}.m4a');
    final srcFile = io.File(sourcePath);
    var finalPath = sourcePath;
    var size = 0;
    if (await srcFile.exists()) {
      final copied = await srcFile.copy(targetPath);
      finalPath = copied.path;
      size = await copied.length();
    }

    return _repo.addAttachment(
      itemId: itemId,
      kind: LumiAttachmentKind.audio,
      path: finalPath,
      name: fileName,
      sizeBytes: size,
      durationMs: durationMs,
    );
  }

  /// Attaches a link and fetches OpenGraph title/description with a fast
  /// timeout, falling back gracefully to parsed URL metadata when offline.
  Future<Attachment> attachLink({
    required String itemId,
    required String rawUrl,
  }) async {
    var normalized = rawUrl.trim();
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    final uri = Uri.tryParse(normalized);
    final host = uri?.host.isNotEmpty == true ? uri!.host : normalized;
    var title = host;
    var description = uri?.path ?? '';

    if (uri != null && !kIsWeb) {
      try {
        final response = await http
            .get(uri, headers: {'User-Agent': 'Lumi/1.0'})
            .timeout(const Duration(seconds: 3));
        if (response.statusCode >= 200 && response.statusCode < 400) {
          final body = response.body;
          final ogTitle = RegExp(
            r'<meta[^>]+property=["\x27]og:title["\x27][^>]+content=["\x27]([^"\x27]+)',
            caseSensitive: false,
          ).firstMatch(body)?.group(1);
          final htmlTitle = RegExp(
            r'<title[^>]*>([^<]+)</title>',
            caseSensitive: false,
          ).firstMatch(body)?.group(1);
          final ogDesc = RegExp(
            r'<meta[^>]+(?:property|name)=["\x27](?:og:)?description["\x27][^>]+content=["\x27]([^"\x27]+)',
            caseSensitive: false,
          ).firstMatch(body)?.group(1);

          final parsedTitle = (ogTitle ?? htmlTitle)?.trim();
          if (parsedTitle != null && parsedTitle.isNotEmpty) {
            title = parsedTitle;
          }
          if (ogDesc != null && ogDesc.trim().isNotEmpty) {
            description = ogDesc.trim();
          }
        }
      } catch (_) {
        // Offline or blocked CORS/timeout: keep crisp URL host fallback.
      }
    }

    return _repo.addAttachment(
      itemId: itemId,
      kind: LumiAttachmentKind.link,
      path: normalized,
      name: title,
      metadata: {'host': host, 'description': description},
    );
  }
}
