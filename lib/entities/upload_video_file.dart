import 'dart:typed_data';

class UploadVideoFile {
  final Uint8List bytes;
  final String filename;
  final String mimeType;

  UploadVideoFile({required this.bytes, required this.filename, required this.mimeType});
}
