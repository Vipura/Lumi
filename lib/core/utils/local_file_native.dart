import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<Uint8List?> readLocalFileBytes(String path) async {
  final file = File(path);
  if (await file.exists()) {
    return file.readAsBytes();
  }
  return null;
}

Future<String?> writeAttachmentBytes(String fileName, Uint8List bytes) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'lumi_attachments'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final target = File(p.join(dir.path, fileName));
  await target.writeAsBytes(bytes);
  return target.path;
}

Future<String?> writeTempFile(String fileName, Uint8List bytes) async {
  final temp = await getTemporaryDirectory();
  final target = File(p.join(temp.path, fileName));
  await target.writeAsBytes(bytes);
  return target.path;
}
