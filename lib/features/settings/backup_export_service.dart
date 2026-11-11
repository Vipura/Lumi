import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/utils/delta_utils.dart';
import '../../core/utils/local_file_io.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/providers.dart';

final backupExportServiceProvider = Provider<LumiBackupExportService>(
  (ref) => LumiBackupExportService(ref.watch(databaseProvider)),
);

class LumiBackupExportService {
  LumiBackupExportService(this._db);

  final LumiDatabase _db;

  Future<void> exportNoteMarkdown(Item item) async {
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
    await _shareBytes(
      bytes: bytes,
      fileName: '$safeName.md',
      mimeType: 'text/markdown',
      subject: item.title,
    );
  }

  Future<void> exportNotePdf(Item item) async {
    final entries = await _db.checklistDao.getEntriesForItem(item.id);
    final plain = DeltaUtils.plainTextFromDeltaJson(item.body);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          pw.Text(
            item.title.isEmpty ? 'Untitled Note' : item.title,
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
        ],
      ),
    );

    final pdfBytes = await doc.save();
    final safeName = _sanitizeFileName(item.title, fallback: 'lumi_note');
    await _shareBytes(
      bytes: pdfBytes,
      fileName: '$safeName.pdf',
      mimeType: 'application/pdf',
      subject: item.title,
    );
  }

  /// Creates a local JSON + attachments `.zip` backup and shares/saves it.
  Future<int> exportFullBackupZip() async {
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
      'version': 1,
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
              'fireAt': r.fireAt.toIso8601String(),
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
    await _shareBytes(
      bytes: zipBytes,
      fileName: 'lumi_backup_$stamp.zip',
      mimeType: 'application/zip',
      subject: 'Lumi Local Backup ($stamp)',
    );
    return items.length;
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
            fireAt: DateTime.parse(m['fireAt'] as String),
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

  Future<void> _shareBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required String subject,
  }) async {
    final writtenPath = await writeTempFile(fileName, bytes);
    final xfile = writtenPath != null
        ? XFile(writtenPath, name: fileName, mimeType: mimeType)
        : XFile.fromData(bytes, name: fileName, mimeType: mimeType);

    await SharePlus.instance.share(
      ShareParams(files: [xfile], subject: subject),
    );
  }

  String _sanitizeFileName(String raw, {required String fallback}) {
    final cleaned = raw
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]+'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return cleaned.isEmpty ? fallback : cleaned;
  }
}
