import 'package:frontend/utils/net_utils.dart';

class API {
  static const baseUrl = "https://catslab.ee.ncku.edu.tw/running_analysis/api";

  static List getRunner = [DioMethod.get, "$baseUrl/runner"];
  static List addRunner = [DioMethod.post, "$baseUrl/runner"];

  static List getRunnerHistory(String runnerId) => [
    DioMethod.get,
    "$baseUrl/runner/$runnerId/run_sessions",
  ];

  static List getRunnerUnanalyzedHistory(String runnerId) => [
    DioMethod.get,
    "$baseUrl/runner/$runnerId/run_sessions/unanalyzed",
  ];

  static List getUnanalyzedRunSessionById(String runSessionId) => [
    DioMethod.get,
    "$baseUrl/run_session/$runSessionId/unanalyzed",
  ];

  static List getRunSessionInfo(String runSessionId) => [
    DioMethod.get,
    "$baseUrl/run_session/$runSessionId",
  ];

  static List getGraphData(String runSessionId) => [
    DioMethod.get,
    "$baseUrl/run_session/$runSessionId/graphs",
  ];

  static List getRunSessionVideo(String runSessionId) => [
    DioMethod.get,
    "$baseUrl/run_session/$runSessionId/video",
  ];

  static List getRunSessionPdf(String runSessionId) => [
    DioMethod.get,
    "$baseUrl/run_session/$runSessionId/pdf",
  ];

  static List getRunSessionCsv(String runSessionId) => [
    DioMethod.get,
    "$baseUrl/run_session/$runSessionId/csv",
  ];

  static List getTempVideoThumbnail(String tempVideoId) => [
    DioMethod.get,
    "$baseUrl/temp_video/$tempVideoId/thumbnail",
  ];

  static List uploadVideo(int index) => [DioMethod.post, "$baseUrl/temp_video/$index"];

  static List uploadAllInfo = [DioMethod.post, "$baseUrl/upload_all_info"];

  static List uploadSeperatelyNew = [DioMethod.post, "$baseUrl/upload_seperately_new"];

  static List uploadSeperatelySelect = [DioMethod.post, "$baseUrl/upload_seperately_select"];

  static List deleteRunSession(String runSessionId) => [
    DioMethod.delete,
    "$baseUrl/run_session/$runSessionId",
  ];

  static List deleteRunner(String runnerId) => [DioMethod.delete, "$baseUrl/runner/$runnerId"];
}
