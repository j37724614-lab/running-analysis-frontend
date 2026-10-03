// ignore_for_file: avoid_print
import 'dart:io';
import 'package:file_picker/file_picker.dart';

void downloadFileFromUrl(String url, String filename) {
  // Not supported or can launch URL in system browser
}

Future<void> saveBytesToFile(List<int> bytes, String filename) async {
  try {
    // 1. Open native Save File dialog
    String? selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: '選擇儲存路徑',
      fileName: filename,
    );

    // 2. Write bytes to local file
    if (selectedPath != null) {
      final file = File(selectedPath);
      await file.writeAsBytes(bytes);
    }
  } catch (e) {
    print('Failed to save file: $e');
  }
}
