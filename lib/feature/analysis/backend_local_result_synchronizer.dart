import 'package:frontend/backend/backend_interface.dart';
import 'package:frontend/feature/analysis/analysis_request.dart';
import 'package:frontend/feature/analysis/local_analysis_adapter.dart';

class BackendLocalResultSynchronizer implements LocalResultSynchronizer {
  BackendLocalResultSynchronizer({required this.backend});

  final BackendInterface backend;

  @override
  Future<LocalSyncResult> sync(AnalysisRequest request, String bundlePath) async {
    final run = await backend.createLocalAnalysisRun(
      runnerId: request.runnerId,
      date: request.date,
      cameraCount: request.cameraCount,
      fps: request.fps,
      isLongJump: request.isLongJump,
      note: request.note,
      comparisonGroupId: request.comparisonGroupId,
    );
    await backend.uploadLocalAnalysisBundle(
      analysisRunId: run.analysisRunId,
      bundlePath: bundlePath,
      idempotencyKey: request.requestId!,
      inputVideoPaths: [for (final video in request.videos) video.path!],
    );
    return LocalSyncResult(runSessionId: run.runSessionId, analysisRunId: run.analysisRunId);
  }
}
