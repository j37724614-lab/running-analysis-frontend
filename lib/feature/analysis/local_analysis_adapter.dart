import 'dart:async';

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
    Duration nativeInactivityTimeout = const Duration(minutes: 5),
    Duration syncTimeout = const Duration(minutes: 5),
  }) : _synchronizer = synchronizer,
       _analysis = analysis ?? native.RunnerAnalysis(),
       _requestIdFactory = requestIdFactory ?? generateUuidV4,
       _nativeInactivityTimeout = nativeInactivityTimeout,
       _syncTimeout = syncTimeout;

  final LocalResultSynchronizer? _synchronizer;

  final native.RunnerAnalysis _analysis;
  final String Function() _requestIdFactory;
  final Duration _nativeInactivityTimeout;
  final Duration _syncTimeout;

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
      includeOverlays: effectiveRequest.generateOverlay,
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

    var lastStage = AnalysisStage.validating;
    try {
      await for (final event
          in _analysis.analyze(nativeRequest).timeout(_nativeInactivityTimeout)) {
        final failure = event.failure;
        if (event.stage == native.LocalAnalysisStage.failed) {
          yield AnalysisEvent.failed(
            error: failure ?? StateError(event.message ?? 'Local analysis failed'),
            message: failure?.message ?? event.message,
            errorCode: failure?.code,
            retriable: failure?.retriable,
          );
          return;
        }
        lastStage = _stage(event.stage);
        if (event.stage == native.LocalAnalysisStage.completed) {
          final bundlePath = event.bundlePath;
          if (bundlePath == null || bundlePath.isEmpty) {
            yield AnalysisEvent.failed(
              error: StateError('Native analysis completed without a bundle path'),
              errorCode: 'missing_bundle_path',
              retriable: true,
            );
            return;
          }
          final synchronizer = _synchronizer;
          if (synchronizer == null) {
            yield AnalysisEvent.completed(bundlePath: bundlePath);
            return;
          }
          yield const AnalysisEvent(stage: AnalysisStage.sync, message: '正在同步 Local 分析結果');
          try {
            final synced = await synchronizer
                .sync(effectiveRequest, bundlePath)
                .timeout(_syncTimeout);
            yield AnalysisEvent.completed(
              runSessionId: synced.runSessionId,
              bundlePath: bundlePath,
            );
          } on TimeoutException catch (error) {
            yield AnalysisEvent.failed(
              error: error,
              message:
                  'Local 分析已完成，但結果同步超過 ${_durationLabel(_syncTimeout)}沒有回應。'
                  '結果檔已保留，可按「Retry Local」重試。',
              bundlePath: bundlePath,
              errorCode: 'sync_timeout',
              retriable: true,
            );
          } catch (error) {
            yield AnalysisEvent.failed(
              error: error,
              message: 'Local 分析已完成，但結果同步失敗。結果檔已保留，可按「Retry Local」重試。',
              bundlePath: bundlePath,
              errorCode: 'sync_failed',
              retriable: true,
            );
          }
          return;
        }
        yield AnalysisEvent(stage: lastStage, progress: event.progress, message: event.message);
      }
    } on TimeoutException catch (error) {
      try {
        await _analysis.cancel();
      } catch (_) {
        // The timeout remains the actionable error even if cancellation fails.
      }
      yield AnalysisEvent.failed(
        error: error,
        message:
            'Local 分析在 ${lastStage.name} 階段超過 '
            '${_durationLabel(_nativeInactivityTimeout)}沒有收到進度或完成訊息，已自動停止。'
            '請按「Retry Local」重試。',
        errorCode: 'local_no_progress_timeout',
        retriable: true,
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

String _durationLabel(Duration duration) {
  if (duration.inMinutes > 0 && duration.inSeconds % 60 == 0) {
    return '${duration.inMinutes} 分鐘';
  }
  return '${duration.inSeconds} 秒';
}
