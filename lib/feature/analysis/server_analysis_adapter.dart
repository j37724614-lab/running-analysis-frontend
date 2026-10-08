import 'dart:async';

import 'package:frontend/backend/backend_interface.dart';
import 'package:frontend/feature/analysis/analysis_event.dart';
import 'package:frontend/feature/analysis/analysis_executor.dart';
import 'package:frontend/feature/analysis/analysis_request.dart';

/// Wraps the existing Server upload flow (`uploadVideo` per camera, then
/// `uploadAllInfo`) behind [AnalysisExecutor] (規劃書 §6 Server 路徑: "保留目前
/// uploadVideo、uploadAllInfo、backend run_analysis() 行為"). Does not change
/// what those calls do - it only re-expresses their existing behavior as an
/// [AnalysisEvent] stream so the UI can treat Server and Local the same way.
class ServerAnalysisAdapter implements AnalysisExecutor {
  ServerAnalysisAdapter({required this.backend});

  final BackendInterface backend;

  bool _cancelRequested = false;

  @override
  Stream<AnalysisEvent> analyze(AnalysisRequest request) {
    final controller = StreamController<AnalysisEvent>();
    _run(request, controller);
    return controller.stream;
  }

  Future<void> _run(AnalysisRequest request, StreamController<AnalysisEvent> controller) async {
    _cancelRequested = false;
    try {
      controller.add(const AnalysisEvent(stage: AnalysisStage.validating));

      final uploadedVideos = <Map<String, dynamic>>[];
      final sortedVideos = [...request.videos]
        ..sort((a, b) => a.cameraIndex.compareTo(b.cameraIndex));

      for (var i = 0; i < sortedVideos.length; i++) {
        if (_cancelRequested) {
          controller.add(const AnalysisEvent(stage: AnalysisStage.sync, message: 'cancelled'));
          await controller.close();
          return;
        }
        final video = sortedVideos[i];
        if (video.tempVideoId != null) {
          uploadedVideos.add({
            'tempVideoId': video.tempVideoId,
            'anchors': video.anchors?.toJson(),
          });
          continue;
        }
        if (video.file == null) {
          throw StateError(
            'ServerAnalysisAdapter requires in-memory video bytes (AnalysisVideoInput.file); '
            'got a path-only input meant for Local analysis',
          );
        }
        controller.add(
          AnalysisEvent(
            stage: AnalysisStage.sync,
            progress: sortedVideos.isEmpty ? null : i / sortedVideos.length,
            message: 'uploading camera ${video.cameraIndex}',
          ),
        );
        final tempVideoId = await backend.uploadVideo(video.cameraIndex, video.file!);
        uploadedVideos.add({'tempVideoId': tempVideoId, 'anchors': video.anchors?.toJson()});
      }

      if (_cancelRequested) {
        controller.add(const AnalysisEvent(stage: AnalysisStage.sync, message: 'cancelled'));
        await controller.close();
        return;
      }

      final runSessionId = await backend.uploadAllInfo(
        request.runnerId,
        request.date,
        request.cameraCount,
        request.fps,
        request.note,
        request.isLongJump,
        uploadedVideos,
        comparisonGroupId: request.comparisonGroupId,
      );

      controller.add(AnalysisEvent.completed(runSessionId: runSessionId));
      await controller.close();
    } catch (error) {
      controller.add(AnalysisEvent.failed(error: error));
      await controller.close();
    }
  }

  @override
  Future<void> cancel() async {
    // Best-effort: stops the adapter from starting the *next* camera upload
    // or the final uploadAllInfo call. An upload already in flight on the
    // wire is not aborted - BackendInterface has no cancellation token today.
    _cancelRequested = true;
  }
}
