import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<bool> saveTextFile({
  required String fileName,
  required String contents,
}) async {
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Export layout',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (path == null || path.isEmpty) {
    return false;
  }

  final file = File(path);
  await file.writeAsString(contents);
  return true;
}
