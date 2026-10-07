import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

Future<FormData> buildLocalBundleForm(
  String bundlePath,
  String idempotencyKey, {
  required List<String> inputVideoPaths,
}) async {
  final root = Directory(bundlePath);
  final manifestFile = File('${root.path}${Platform.pathSeparator}manifest.json');
  final manifest = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
  final artifactFiles = <MultipartFile>[];
  for (final artifact in manifest['artifacts'] as List<dynamic>? ?? const []) {
    final relativePath = (artifact as Map<String, dynamic>)['relative_path'] as String;
    if (_unsafe(relativePath)) {
      throw FormatException('Unsafe artifact path in local manifest: $relativePath');
    }
    final path =
        '${root.path}${Platform.pathSeparator}'
        '${relativePath.replaceAll('/', Platform.pathSeparator)}';
    artifactFiles.add(await MultipartFile.fromFile(path, filename: relativePath));
  }
  return FormData.fromMap({
    'manifest': await MultipartFile.fromFile(manifestFile.path, filename: 'manifest.json'),
    'artifacts': artifactFiles,
    'idempotency_key': idempotencyKey,
    'input_videos': [
      for (final path in inputVideoPaths)
        await MultipartFile.fromFile(path, filename: File(path).uri.pathSegments.last),
    ],
  });
}

bool _unsafe(String path) => path.isEmpty || path.startsWith('/') || path.split('/').contains('..');
