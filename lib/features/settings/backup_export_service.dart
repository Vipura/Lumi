import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, compute, defaultTargetPlatform, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/utils/delta_utils.dart';
import '../../core/utils/local_file_io.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';

final backupExportServiceProvider = Provider<LumiBackupExportService>(
  (ref) => LumiBackupExportService(ref.watch(databaseProvider)),
);

Uint8List? _normalizePdfImageBytes(Uint8List rawBytes) {
  final decoded = img.decodeImage(rawBytes);
  if (decoded == null) return null;
  var image = img.bakeOrientation(decoded);
  if (image.width > 1400 || image.height > 1400) {
    image = img.copyResize(
      image,
      width: image.width >= image.height ? 1400 : null,
      height: image.height > image.width ? 1400 : null,
    );
  }
  if (image.numChannels == 4 || image.hasPalette) {
    return Uint8List.fromList(img.encodePng(image));
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 88));
}

class LumiBackupExportService {
  LumiBackupExportService(this._db);

  final LumiDatabase _db;

  Future<bool> exportNoteMarkdown(Item item) async {
    final entries = await _db.checklistDao.getEntriesForItem(item.id);
    final buf = StringBuffer(
      DeltaUtils.markdownFromDeltaJson(item.body, title: item.title),
    );
    if (entries.isNotEmpty) {
      buf.writeln('\n\n## Checklist');
      for (final e in entries) {
        final indent = e.parentId != null ? '  ' : '';
        buf.writeln('$indent- [${e.done ? 'x' : ' '}] ${e.entryText}');
      }
    }

    final bytes = Uint8List.fromList(utf8.encode(buf.toString()));
    final safeName = _sanitizeFileName(item.title, fallback: 'lumi_note');
    return _shareBytes(
      bytes: bytes,
      fileName: '$safeName.md',
      mimeType: 'text/markdown',
      subject: item.title,
    );
  }

  /// Renders [item], its plain text, checklist entries, and any attached images
  /// into a portable A4 PDF document.
  Future<Uint8List> buildNotePdfBytes(Item item) async {
    final entries = await _db.checklistDao.getEntriesForItem(item.id);
    final attachments = await _db.attachmentsDao.getAttachmentsForItem(item.id);
    final plainFromDelta = DeltaUtils.plainTextFromDeltaJson(item.body);
    final plain = plainFromDelta.isNotEmpty ? plainFromDelta : item.plainText;

    final pdfImages = <({String name, Uint8List bytes})>[];
    for (final att in attachments) {
      if (att.kind != LumiAttachmentKind.image.dbValue) continue;
      final rawBytes = await _loadImageAttachmentBytes(att);
      if (rawBytes == null || rawBytes.isEmpty) continue;
      final normalized = await compute(_normalizePdfImageBytes, rawBytes);
      final resolved = normalized ?? rawBytes;
      if (resolved.isEmpty) continue;
      pdfImages.add((name: att.name, bytes: resolved));
    }

    final type = LumiItemType.fromDb(item.type);
    final defaultTitle = switch (type) {
      LumiItemType.calm => 'Calm Space Entry',
      LumiItemType.checklist => 'Checklist',
      LumiItemType.card => 'Plan',
      _ => 'Untitled Note',
    };

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          pw.Text(
            item.title.trim().isEmpty ? defaultTitle : item.title.trim(),
            style: const pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 12),
          if (plain.isNotEmpty)
            pw.Text(
              plain,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
            ),
          if (entries.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Checklist',
              style: const pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            ...entries.map(
              (e) => pw.Padding(
                padding: pw.EdgeInsets.only(
                  left: e.parentId != null ? 16 : 0,
                  bottom: 4,
                ),
                child: pw.Text(
                  '${e.done ? '[x]' : '[ ]'} ${e.entryText}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
          if (pdfImages.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            pw.Text(
              'Attached Photos',
              style: const pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            for (final imgEntry in pdfImages) ...[
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.7),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.ConstrainedBox(
                      constraints: const pw.BoxConstraints(maxHeight: 280),
                      child: pw.Center(
                        child: pw.Image(
                          pw.MemoryImage(imgEntry.bytes),
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    ),
                    if (imgEntry.name.isNotEmpty) ...[
                      pw.SizedBox(height: 6),
                      pw.Text(
                        imgEntry.name,
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );

    return doc.save();
  }

  Future<bool> exportNotePdf(Item item) async {
    final pdfBytes = await buildNotePdfBytes(item);
    final fallback = item.type == LumiItemType.calm.dbValue
        ? 'lumi_calm_entry'
        : 'lumi_note';
    final safeName = _sanitizeFileName(item.title, fallback: fallback);
    return _shareBytes(
      bytes: pdfBytes,
      fileName: '$safeName.pdf',
      mimeType: 'application/pdf',
      subject: item.title,
    );
  }

  Future<Uint8List?> _loadImageAttachmentBytes(Attachment att) async {
    Uint8List? decodeDataUrl(String? raw) {
      if (raw == null || !raw.startsWith('data:')) return null;
      final commaIdx = raw.indexOf(',');
      if (commaIdx == -1 || commaIdx + 1 >= raw.length) return null;
      try {
        return base64Decode(raw.substring(commaIdx + 1));
      } catch (_) {
        return null;
      }
    }

    final fromPathDataUrl = decodeDataUrl(att.path);
    if (fromPathDataUrl != null) return fromPathDataUrl;

    if (!att.path.startsWith('http')) {
      final bytes = await readLocalFileBytes(att.path);
      if (bytes != null && bytes.isNotEmpty) return bytes;
    }

    if (att.metadataJson != null) {
      try {
        final meta = jsonDecode(att.metadataJson!) as Map<String, dynamic>;
        final thumbPath = meta['thumbPath'] as String?;
        if (thumbPath != null && thumbPath.isNotEmpty) {
          final thumbBytes = await readLocalFileBytes(thumbPath);
          if (thumbBytes != null && thumbBytes.isNotEmpty) return thumbBytes;
        }
        final thumbData = decodeDataUrl(meta['thumbDataUrl'] as String?);
        if (thumbData != null) return thumbData;
      } catch (_) {}
    }

    return null;
  }

  /// Creates a local JSON + attachments `.zip` backup and shares/saves it.
  /// Returns the exported item count, or `null` if the user cancelled saving.
  Future<int?> exportFullBackupZip() async {
    final items = await _db.select(_db.items).get();
    final entries = await _db.select(_db.checklistEntries).get();
    final reminders = await _db.remindersDao.getAllReminders();
    final attachments = await _db.attachmentsDao.getAllAttachments();
    final collections = await _db.organizationDao.getCollections();
    final tags = await _db.organizationDao.getAllTags();
    final itemTags = await _db.organizationDao.getAllItemTags();

    final archive = Archive();
    final attachmentExports = <Map<String, dynamic>>[];

    for (final att in attachments) {
      String? archiveRelPath;
      if (!att.path.startsWith('http') && !att.path.startsWith('data:')) {
        final bytes = await readLocalFileBytes(att.path);
        if (bytes != null) {
          archiveRelPath = 'attachments/${att.id}_${p.basename(att.path)}';
          archive.addFile(ArchiveFile(archiveRelPath, bytes.length, bytes));
        }
      }
      attachmentExports.add({
        'id': att.id,
        'itemId': att.itemId,
        'kind': att.kind,
        'path': att.path,
        'archivePath': archiveRelPath,
        'name': att.name,
        'sizeBytes': att.sizeBytes,
        'durationMs': att.durationMs,
        'metadataJson': att.metadataJson,
        'createdAt': att.createdAt.toIso8601String(),
      });
    }

    final payload = {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'collections': collections
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'iconName': c.iconName,
              'colorValue': c.colorValue,
              'sortOrder': c.sortOrder,
            },
          )
          .toList(),
      'tags': tags
          .map((t) => {'id': t.id, 'name': t.name, 'colorValue': t.colorValue})
          .toList(),
      'items': items
          .map(
            (i) => {
              'id': i.id,
              'type': i.type,
              'title': i.title,
              'body': i.body,
              'plainText': i.plainText,
              'colorValue': i.colorValue,
              'pinned': i.pinned,
              'archived': i.archived,
              'deletedAt': i.deletedAt?.toIso8601String(),
              'collectionId': i.collectionId,
              'boardStatus': i.boardStatus,
              'dueDate': i.dueDate?.toIso8601String(),
              'stickyX': i.stickyX,
              'stickyY': i.stickyY,
              'stickyW': i.stickyW,
              'stickyH': i.stickyH,
              'stickyZ': i.stickyZ,
              'createdAt': i.createdAt.toIso8601String(),
              'updatedAt': i.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'checklistEntries': entries
          .map(
            (e) => {
              'id': e.id,
              'itemId': e.itemId,
              'text': e.entryText,
              'done': e.done,
              'sortOrder': e.sortOrder,
              'parentId': e.parentId,
              'completedAt': e.completedAt?.toIso8601String(),
            },
          )
          .toList(),
      'reminders': reminders
          .map(
            (r) => {
              'id': r.id,
              'itemId': r.itemId,
              'entryId': r.entryId,
              'title': r.title,
              'fireAt': r.fireAt.toIso8601String(),
              'earlyReminderMinutes': r.earlyReminderMinutes,
              'repeatRule': r.repeatRule,
              'status': r.status,
              'notificationId': r.notificationId,
            },
          )
          .toList(),
      'itemTags': itemTags
          .map((it) => {'itemId': it.itemId, 'tagId': it.tagId})
          .toList(),
      'attachments': attachmentExports,
    };

    final jsonBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    archive.addFile(
      ArchiveFile('lumi_backup.json', jsonBytes.length, jsonBytes),
    );

    final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive));
    final stamp = DateTime.now().toIso8601String().split('T').first;
    final exported = await _shareBytes(
      bytes: zipBytes,
      fileName: 'lumi_backup_$stamp.zip',
      mimeType: 'application/zip',
      subject: 'Lumi Local Backup ($stamp)',
    );
    return exported ? items.length : null;
  }

  /// Picks a `.zip` backup file and restores all items, checklists, tags,
  /// reminders, and attachment files cleanly into the database.
  Future<int> restoreBackupFromPicker() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (file == null) return 0;

    final filePath = file.path;
    final bytes = (!kIsWeb && filePath != null)
        ? (await readLocalFileBytes(filePath) ?? await file.readAsBytes())
        : await file.readAsBytes();
    if (bytes.isEmpty) return 0;

    return restoreBackupBytes(bytes);
  }

  Future<int> restoreBackupBytes(Uint8List zipBytes) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final jsonFile = archive.findFile('lumi_backup.json');
    if (jsonFile == null) {
      throw const FormatException(
        'Missing lumi_backup.json in backup archive.',
      );
    }
    final data = jsonDecode(
      utf8.decode(jsonFile.content as List<int>),
    ) as Map<String, dynamic>;

    final restoredFiles = <String, String>{};
    for (final entry in archive.files) {
      if (entry.isFile && entry.name.startsWith('attachments/')) {
        final content = Uint8List.fromList(entry.content as List<int>);
        final written = await writeAttachmentBytes(
          p.basename(entry.name),
          content,
        );
        if (written != null) {
          restoredFiles[entry.name] = written;
        }
      }
    }

    var restoredItems = 0;
    await _db.transaction(() async {
      for (final raw in (data['collections'] as List? ?? const [])) {
        final m = raw as Map<String, dynamic>;
        await _db.organizationDao.upsertCollection(
          CollectionsCompanion.insert(
            id: m['id'] as String,
            name: m['name'] as String,
            iconName: Value(m['iconName'] as String? ?? 'folder'),
            colorValue: m['colorValue'] as int,
            sortOrder: Value(m['sortOrder'] as int? ?? 0),
          ),
        );
      }

      for (final raw in (data['tags'] as List? ?? const [])) {
        final m = raw as Map<String, dynamic>;
        await _db.organizationDao.upsertTag(
          TagsCompanion.insert(
            id: m['id'] as String,
            name: m['name'] as String,
            colorValue: Value(m['colorValue'] as int?),
          ),
        );
      }

      for (final raw in (data['items'] as List? ?? const [])) {
        final m = raw as Map<String, dynamic>;
        await _db.itemsDao.upsertItem(
          ItemsCompanion.insert(
            id: m['id'] as String,
            type: m['type'] as String,
            title: Value(m['title'] as String? ?? ''),
            body: Value(m['body'] as String? ?? DeltaUtils.emptyDeltaJson()),
            plainText: Value(m['plainText'] as String? ?? ''),
            colorValue: Value(m['colorValue'] as int?),
            pinned: Value(m['pinned'] as bool? ?? false),
            archived: Value(m['archived'] as bool? ?? false),
            deletedAt: Value(
              m['deletedAt'] != null
                  ? DateTime.parse(m['deletedAt'] as String)
                  : null,
            ),
            collectionId: Value(m['collectionId'] as String?),
            boardStatus: Value(m['boardStatus'] as String? ?? 'todo'),
            dueDate: Value(
              m['dueDate'] != null
                  ? DateTime.parse(m['dueDate'] as String)
                  : null,
            ),
            stickyX: Value((m['stickyX'] as num?)?.toDouble()),
            stickyY: Value((m['stickyY'] as num?)?.toDouble()),
            stickyW: Value((m['stickyW'] as num?)?.toDouble()),
            stickyH: Value((m['stickyH'] as num?)?.toDouble()),
            stickyZ: Value(m['stickyZ'] as int?),
            createdAt: DateTime.parse(m['createdAt'] as String),
            updatedAt: DateTime.parse(m['updatedAt'] as String),
          ),
        );
        restoredItems++;
      }

      for (final raw in (data['checklistEntries'] as List? ?? const [])) {
        final m = raw as Map<String, dynamic>;
        await _db.checklistDao.upsertEntry(
          ChecklistEntriesCompanion.insert(
            id: m['id'] as String,
            itemId: m['itemId'] as String,
            entryText: m['text'] as String,
            done: Value(m['done'] as bool? ?? false),
            sortOrder: Value(m['sortOrder'] as int? ?? 0),
            parentId: Value(m['parentId'] as String?),
            completedAt: Value(
              m['completedAt'] != null
                  ? DateTime.parse(m['completedAt'] as String)
                  : null,
            ),
          ),
        );
      }

      for (final raw in (data['reminders'] as List? ?? const [])) {
        final m = raw as Map<String, dynamic>;
        await _db.remindersDao.upsertReminder(
          RemindersCompanion.insert(
            id: m['id'] as String,
            itemId: m['itemId'] as String,
            entryId: Value(m['entryId'] as String?),
            title: Value(m['title'] as String? ?? ''),
            fireAt: DateTime.parse(m['fireAt'] as String),
            earlyReminderMinutes: Value(m['earlyReminderMinutes'] as int? ?? 0),
            repeatRule: Value(m['repeatRule'] as String? ?? 'none'),
            status: Value(m['status'] as String? ?? 'scheduled'),
            notificationId: m['notificationId'] as int,
          ),
        );
      }

      for (final raw in (data['itemTags'] as List? ?? const [])) {
        final m = raw as Map<String, dynamic>;
        await _db.organizationDao.attachTagToItem(
          m['itemId'] as String,
          m['tagId'] as String,
        );
      }

      for (final raw in (data['attachments'] as List? ?? const [])) {
        final m = raw as Map<String, dynamic>;
        final archPath = m['archivePath'] as String?;
        final resolvedPath =
            (archPath != null && restoredFiles.containsKey(archPath))
            ? restoredFiles[archPath]!
            : m['path'] as String;
        await _db.attachmentsDao.upsertAttachment(
          AttachmentsCompanion.insert(
            id: m['id'] as String,
            itemId: m['itemId'] as String,
            kind: m['kind'] as String,
            path: resolvedPath,
            name: m['name'] as String,
            sizeBytes: Value(m['sizeBytes'] as int? ?? 0),
            durationMs: Value(m['durationMs'] as int?),
            metadataJson: Value(m['metadataJson'] as String?),
            createdAt: DateTime.parse(m['createdAt'] as String),
          ),
        );
      }
    });
    return restoredItems;
  }

  bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<bool> _shareBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required String subject,
  }) async {
    if (_isDesktop) {
      try {
        final saved = await FilePicker.saveFile(
          dialogTitle: 'Save $fileName',
          fileName: fileName,
          mimeType: mimeType,
          bytes: bytes,
        );
        return saved != null;
      } catch (_) {
        if (defaultTargetPlatform == TargetPlatform.linux) {
          rethrow;
        }
      }
    }

    final writtenPath = await writeTempFile(fileName, bytes);
    final xfile = writtenPath != null
        ? XFile(writtenPath, name: fileName, mimeType: mimeType)
        : XFile.fromData(bytes, name: fileName, mimeType: mimeType);

    await SharePlus.instance.share(
      ShareParams(files: [xfile], subject: subject),
    );
    return true;
  }

  String _sanitizeFileName(String raw, {required String fallback}) {
    final cleaned = raw
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]+'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return cleaned.isEmpty ? fallback : cleaned;
  }
}
