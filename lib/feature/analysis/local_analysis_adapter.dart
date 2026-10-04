import 'package:frontend/feature/analysis/analysis_event.dart';
import 'package:frontend/feature/analysis/analysis_executor.dart';
import 'package:frontend/feature/analysis/analysis_request.dart';
import 'package:frontend/feature/analysis/uuid_v4.dart';
import 'package:runner_pose/runner_analysis.dart' as native;

/// Path-based on-device adapter. Video bytes never pass through Dart or a
/// platform channel; RunnerAnalysisKit opens and hashes each local file.
class LocalAnalysisAdapter implements AnalysisExecutor, DisposableAnalysisExecutor {
  LocalAnalysisAdapter({
    native.RunnerAnalysis? analysis,
    LocalResultSynchronizer? synchronizer,
    String Function()? requestIdFactory,
  }) : _synchronizer = synchronizer,
       _analysis = analysis ?? native.RunnerAnalysis(),
       _requestIdFactory = requestIdFactory ?? generateUuidV4;

  final LocalResultSynchronizer? _synchronizer;

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

    final effectiveRequest = request.withRunIdentifiers(
      requestId: request.requestId ?? _requestIdFactory(),
    );
    final nativeRequest = native.LocalAnalysisRequest(
      schemaVersion: request.schemaVersion,
      requestId: effectiveRequest.requestId!,
      comparisonGroupId: effectiveRequest.comparisonGroupId,
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
        final bundlePath = event.bundlePath;
        if (bundlePath == null || bundlePath.isEmpty) {
          yield AnalysisEvent.failed(
            error: StateError('Native analysis completed without a bundle path'),
            errorCode: 'missing_bundle_path',
            retriable: true,
          );
          continue;
        }
        final synchronizer = _synchronizer;
        if (synchronizer == null) {
          yield AnalysisEvent.completed(bundlePath: bundlePath);
          continue;
        }
        yield const AnalysisEvent(stage: AnalysisStage.sync, message: 'syncing local result');
        try {
          final synced = await synchronizer.sync(effectiveRequest, bundlePath);
          yield AnalysisEvent.completed(runSessionId: synced.runSessionId, bundlePath: bundlePath);
        } catch (error) {
          yield AnalysisEvent.failed(
            error: error,
            message: 'Local analysis finished, but result sync failed. The local bundle was kept.',
            errorCode: 'sync_failed',
            retriable: true,
          );
        }
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

class LocalSyncResult {
  const LocalSyncResult({required this.runSessionId, required this.analysisRunId});

  final String runSessionId;
  final String analysisRunId;
}

abstract interface class LocalResultSynchronizer {
  Future<LocalSyncResult> sync(AnalysisRequest request, String bundlePath);
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
