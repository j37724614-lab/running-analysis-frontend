import 'package:dio/dio.dart';
import 'package:frontend/backend/backend_interface.dart';
import 'package:frontend/entities/graph_data.dart';
import 'package:frontend/entities/runner_info.dart';
import 'package:frontend/entities/step_data.dart';
import 'package:frontend/entities/toe_path_data.dart';
import 'package:frontend/entities/unanalyzed_run_session_info.dart';
import 'package:frontend/entities/upload_seperately_status.dart';
import 'package:frontend/entities/upload_video_file.dart';
import 'package:frontend/entities/run_session_info.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';
import 'package:frontend/utils/api.dart';
import 'package:frontend/utils/net_utils.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

class RestBackendRepo implements BackendInterface {
  @override
  Future<List<RunnerInfo>> getRunners() async {
    final List response = await NetUtils().reqeustData<List>(
      API.getRunner[1],
      method: API.getRunner[0],
    );
    return response.map((e) => RunnerInfo.fromJson(e)).toList();
  }

  @override
  Future<List<GraphData>> getGraphData(String runSessionId) async {
    final response = await NetUtils().reqeustData(
      API.getGraphData(runSessionId)[1],
      method: API.getGraphData(runSessionId)[0],
    );
    return (response as List).map((e) => GraphData.fromJson(e)).toList();
  }

  @override
  Future<RunSessionInfo> getRunSessionInfo(String runSessionId) async {
    final response = await NetUtils().reqeustData(
      API.getRunSessionInfo(runSessionId)[1],
      method: API.getRunSessionInfo(runSessionId)[0],
    );
    return RunSessionInfo.fromJson(response);
  }

  @override
  Future<List<RunSessionInfo>> getRunnerHistory(String runnerId) async {
    final response = await NetUtils().reqeustData(
      API.getRunnerHistory(runnerId)[1],
      method: API.getRunnerHistory(runnerId)[0],
    );
    return (response as List).map((e) => RunSessionInfo.fromJson(e)).toList();
  }

  @override
  Future<String> uploadVideo(int index, UploadVideoFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        file.bytes,
        filename: file.filename,
        contentType: MediaType.parse(file.mimeType),
      ),
    });

    final response = await NetUtils().reqeustData(
      API.uploadVideo(index)[1],
      method: API.uploadVideo(index)[0],
      postData: formData,
    );
    return response['tempVideoId'];
  }

  @override
  Future<String> uploadAllInfo(
    String runnerId,
    DateTime date,
    int cameraCount,
    int fps,
    String note,
    bool isLongJump,
    List<Map<String, dynamic>> videos,
  ) async {
    final response = await NetUtils().reqeustData(
      API.uploadAllInfo[1],
      method: API.uploadAllInfo[0],
      postData: {
        "runnerId": runnerId,
        "date": DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
        "cameraCount": cameraCount,
        "fps": fps,
        "note": note,
        "isLongJump": isLongJump,
        "videos": videos,
      },
    );
    return response['runSessionId'];
  }

  @override
  Future<List<UnanalyzedRunSessionInfo>> getRunnerUnanalyzedHistory(String runnerId) async {
    final response = await NetUtils().reqeustData(
      API.getRunnerUnanalyzedHistory(runnerId)[1],
      method: API.getRunnerUnanalyzedHistory(runnerId)[0],
    );
    return (response as List).map((e) => UnanalyzedRunSessionInfo.fromJson(e)).toList();
  }

  @override
  Future<UnanalyzedRunSessionInfo?> getUnanalyzedRunSessionById(String runSessionId) async {
    try {
      final response = await NetUtils().reqeustData(
        API.getUnanalyzedRunSessionById(runSessionId)[1],
        method: API.getUnanalyzedRunSessionById(runSessionId)[0],
      );
      if (response != null) {
        return UnanalyzedRunSessionInfo.fromJson(response);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
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
  ) async {
    final response = await NetUtils().reqeustData(
      API.uploadSeperatelyNew[1],
      method: API.uploadSeperatelyNew[0],
      postData: {
        "runnerId": runnerId,
        "date": DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
        "cameraCount": cameraCount,
        "fps": fps,
        "note": note,
        "isLongJump": isLongJump,
        "cameraIndex": cameraIndex,
        "tempVideoId": tempVideoId,
        "anchors": anchors?.toJson(),
      },
    );
    return UploadSeperatelyStatus.fromJson(response);
  }

  @override
  Future<UploadSeperatelyStatus> uploadSeperatelySelect(
    String runnerId,
    String runSessionId,
    int cameraIndex,
    String tempVideoId,
    AnchorResult? anchors,
  ) async {
    final response = await NetUtils().reqeustData(
      API.uploadSeperatelySelect[1],
      method: API.uploadSeperatelySelect[0],
      postData: {
        "runnerId": runnerId,
        "runSessionId": runSessionId,
        "cameraIndex": cameraIndex,
        "tempVideoId": tempVideoId,
        "anchors": anchors?.toJson(),
      },
    );
    return UploadSeperatelyStatus.fromJson(response);
  }

  @override
  Future<String> addRunner(String name) async {
    final response = await NetUtils().reqeustData(
      API.addRunner[1],
      method: API.addRunner[0],
      postData: {"name": name},
    );
    return response['id'];
  }

  @override
  Future<List<int>> getRunSessionPdf(String runSessionId) async {
    return await NetUtils().requestBytes(API.getRunSessionPdf(runSessionId)[1]);
  }

  @override
  Future<List<int>> getRunSessionCsv(String runSessionId) async {
    return await NetUtils().requestBytes(API.getRunSessionCsv(runSessionId)[1]);
  }

  @override
  Future<void> deleteRunSession(String runSessionId) async {
    await NetUtils().reqeustData(
      API.deleteRunSession(runSessionId)[1],
      method: API.deleteRunSession(runSessionId)[0],
    );
  }

  @override
  Future<void> deleteRunner(String runnerId) async {
    await NetUtils().reqeustData(
      API.deleteRunner(runnerId)[1],
      method: API.deleteRunner(runnerId)[0],
    );
  }

  @override
  Future<StepsData> getRunSessionSteps(String runSessionId) async {
    final response = await NetUtils().reqeustData(
      API.getRunSessionSteps(runSessionId)[1],
      method: API.getRunSessionSteps(runSessionId)[0],
    );
    return StepsData.fromJson(response);
  }

  @override
  Future<ToePathData> getRunSessionToePath(String runSessionId) async {
    final response = await NetUtils().reqeustData(
      API.getRunSessionToePath(runSessionId)[1],
      method: API.getRunSessionToePath(runSessionId)[0],
    );
    return ToePathData.fromJson(response);
  }

  @override
  Future<List<int>> getTopdownReviewCameraIndices(String runSessionId) async {
    final response = await NetUtils().reqeustData(
      API.getTopdownReviewCameraIndices(runSessionId)[1],
      method: API.getTopdownReviewCameraIndices(runSessionId)[0],
    );
    return (response['cameraIndices'] as List).map((e) => e as int).toList();
  }
}
