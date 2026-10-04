import 'package:frontend/entities/graph_data.dart';
import 'package:frontend/entities/runner_info.dart';
import 'package:frontend/entities/step_data.dart';
import 'package:frontend/entities/toe_path_data.dart';
import 'package:frontend/entities/unanalyzed_run_session_info.dart';
import 'package:frontend/entities/upload_seperately_status.dart';
import 'package:frontend/entities/upload_video_file.dart';
import 'package:frontend/entities/run_session_info.dart';
import 'package:frontend/entities/local_analysis_run_ref.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';

abstract class BackendInterface {
  Future<List<RunnerInfo>> getRunners();
  Future<List<GraphData>> getGraphData(String runSessionId);
  Future<RunSessionInfo> getRunSessionInfo(String runSessionId);
  Future<List<RunSessionInfo>> getRunnerHistory(String runnerId);
  Future<List<UnanalyzedRunSessionInfo>> getRunnerUnanalyzedHistory(String runnerId);
  Future<UnanalyzedRunSessionInfo?> getUnanalyzedRunSessionById(String runSessionId);

  Future<String> addRunner(String name);
  Future<String> uploadAllInfo(
    String runnerId,
    DateTime date,
    int cameraCount,
    int fps,
    String note,
    bool isLongJump,
    List<Map<String, dynamic>> videos,
  );
  Future<UploadSeperatelyStatus> uploadSeperatelyNew(
    String runnerId,
    DateTime date,
    int cameraCount,
    int fps,
    String note,
    bool isLongJump,
    int cameraIndex,
    String tempVideoId,
    AnchorResult? anchors,
  );
  Future<UploadSeperatelyStatus> uploadSeperatelySelect(
    String runnerId,
    String runSessionId,
    int cameraIndex,
    String tempVideoId,
    AnchorResult? anchors,
  );
  Future<String> uploadVideo(int index, UploadVideoFile file);
  Future<LocalAnalysisRunRef> createLocalAnalysisRun({
    required String runnerId,
    required DateTime date,
    required int cameraCount,
    required int fps,
    required bool isLongJump,
    required String note,
    String? comparisonGroupId,
  });
  Future<void> uploadLocalAnalysisBundle({
    required String analysisRunId,
    required String bundlePath,
    required String idempotencyKey,
  });
  Future<List<int>> getRunSessionPdf(String runSessionId);
  Future<List<int>> getRunSessionCsv(String runSessionId);
  Future<void> deleteRunSession(String runSessionId);
  Future<void> deleteRunner(String runnerId);

  // -- Trial review (long-jump 賽事回顧 page) --
  Future<StepsData> getRunSessionSteps(String runSessionId);
  Future<ToePathData> getRunSessionToePath(String runSessionId);
  Future<List<int>> getTopdownReviewCameraIndices(String runSessionId);
}
