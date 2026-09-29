import 'package:frontend/entities/graph_data.dart';
import 'package:frontend/entities/runner_info.dart';
import 'package:frontend/entities/unanalyzed_run_session_info.dart';
import 'package:frontend/entities/upload_seperately_status.dart';
import 'package:frontend/entities/upload_video_file.dart';
import 'package:frontend/entities/run_session_info.dart';
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
    List<Map<String, dynamic>> videos,
  );
  Future<UploadSeperatelyStatus> uploadSeperatelyNew(
    String runnerId,
    DateTime date,
    int cameraCount,
    int fps,
    String note,
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
  Future<List<int>> getRunSessionPdf(String runSessionId);
  Future<List<int>> getRunSessionCsv(String runSessionId);
  Future<void> deleteRunSession(String runSessionId);
  Future<void> deleteRunner(String runnerId);
}
