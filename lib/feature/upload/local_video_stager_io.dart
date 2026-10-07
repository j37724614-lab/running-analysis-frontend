import 'dart:io';

import 'package:frontend/feature/upload/local_video_stager.dart';
import 'package:path_provider/path_provider.dart';

typedef StagingDirectoryProvider = Future<Directory> Function();

LocalVideoStager createPlatformLocalVideoStager() => IoLocalVideoStager();

class IoLocalVideoStager implements LocalVideoStager {
  IoLocalVideoStager({StagingDirectoryProvider? rootDirectory})
    : _rootDirectory = rootDirectory ?? _defaultRootDirectory;

  final StagingDirectoryProvider _rootDirectory;

  static Future<Directory> _defaultRootDirectory() async {
    final applicationSupport = await getApplicationSupportDirectory();
    return Directory('${applicationSupport.path}${Platform.pathSeparator}LocalAnalysisInputs');
  }

  @override
  Future<String> stage({required String sourcePath, required String filename}) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('選取的影片已不存在，請重新選擇。', sourcePath);
    }

    final root = await _rootDirectory();
    await root.create(recursive: true);
    final safeName = _safeFilename(filename);
    final token = DateTime.now().microsecondsSinceEpoch;
    final destination = File('${root.path}${Platform.pathSeparator}$token-$safeName');
    final partial = File('${destination.path}.partial');

    try {
      await source.copy(partial.path);
      await partial.rename(destination.path);
      return destination.path;
    } catch (_) {
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
  }

  @override
  Future<void> remove(String stagedPath) async {
    final root = await _rootDirectory();
    final rootPrefix = '${root.absolute.path}${Platform.pathSeparator}';
    final file = File(stagedPath).absolute;
    if (!file.path.startsWith(rootPrefix)) return;
    if (await file.exists()) await file.delete();
  }
}

String _safeFilename(String filename) {
  final sanitized = filename.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  return sanitized.isEmpty ? 'video.mov' : sanitized;
}
