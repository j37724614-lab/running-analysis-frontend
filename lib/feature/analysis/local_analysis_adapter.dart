import 'dart:math';

import 'package:frontend/feature/analysis/analysis_event.dart';
import 'package:frontend/feature/analysis/analysis_executor.dart';
import 'package:frontend/feature/analysis/analysis_request.dart';
import 'package:runner_pose/runner_analysis.dart' as native;

/// Path-based on-device adapter. Video bytes never pass through Dart or a
/// platform channel; RunnerAnalysisKit opens and hashes each local file.
class LocalAnalysisAdapter implements AnalysisExecutor, DisposableAnalysisExecutor {
  LocalAnalysisAdapter({native.RunnerAnalysis? analysis, String Function()? requestIdFactory})
    : _analysis = analysis ?? native.RunnerAnalysis(),
      _requestIdFactory = requestIdFactory ?? _uuidV4;

  final native.RunnerAnalysis _analysis;
  final String Function() _requestIdFactory;

  @override
  Stream<AnalysisEvent> analyze(AnalysisRequest request) async* {
    final missingPath = request.videos.where((video) => video.path == null).toList();
    if (missingPath.isNotEmpty) {
      yield AnalysisEvent.failed(
        error: ArgumentError('Local analysis requires a filesystem path for every video'),
        message: '請重新選擇影片，Local 模式不會把影片 bytes 傳進原生層。',
        errorCode: 'missing_local_path',
        retriable: true,
      );
      return;
    }

    final nativeRequest = native.LocalAnalysisRequest(
      schemaVersion: request.schemaVersion,
      requestId: _requestIdFactory(),
      // Empty means the native plugin selects Application Support/RunnerAnalysisResults.
      outputDirectoryPath: '',
      videos: [
        for (final video in request.videos)
          native.LocalAnalysisVideo(
            cameraIndex: video.cameraIndex,
            path: video.path!,
            fps: video.fps,
            width: video.frameWidth,
            height: video.frameHeight,
            rotationDegrees: video.rotationDegrees,
          ),
      ],
    );

    await for (final event in _analysis.analyze(nativeRequest)) {
      final failure = event.failure;
      if (event.stage == native.LocalAnalysisStage.failed) {
        yield AnalysisEvent.failed(
          error: failure ?? StateError(event.message ?? 'Local analysis failed'),
          message: failure?.message ?? event.message,
          errorCode: failure?.code,
          retriable: failure?.retriable,
        );
        continue;
      }
      if (event.stage == native.LocalAnalysisStage.completed) {
        yield AnalysisEvent.completed(bundlePath: event.bundlePath);
        continue;
      }
      yield AnalysisEvent(
        stage: _stage(event.stage),
        progress: event.progress,
        message: event.message,
      );
    }
  }

  @override
  Future<void> cancel() => _analysis.cancel();

  @override
  Future<void> dispose() => _analysis.dispose();
}

AnalysisStage _stage(native.LocalAnalysisStage stage) => switch (stage) {
  native.LocalAnalysisStage.validating => AnalysisStage.validating,
  native.LocalAnalysisStage.prescan => AnalysisStage.prescan,
  native.LocalAnalysisStage.tracking => AnalysisStage.tracking,
  native.LocalAnalysisStage.pose2d => AnalysisStage.pose2d,
  native.LocalAnalysisStage.pose3d => AnalysisStage.pose3d,
  native.LocalAnalysisStage.speed => AnalysisStage.speed,
  native.LocalAnalysisStage.gait => AnalysisStage.gait,
  native.LocalAnalysisStage.export => AnalysisStage.export,
  native.LocalAnalysisStage.sync => AnalysisStage.sync,
  native.LocalAnalysisStage.completed => AnalysisStage.completed,
  native.LocalAnalysisStage.failed => AnalysisStage.failed,
};

String _uuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
