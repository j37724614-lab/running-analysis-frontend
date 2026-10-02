import 'dart:math';

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
import 'package:frontend/utils/test_data.dart';

class FakeBackendRepo implements BackendInterface {
  @override
  Future<List<RunnerInfo>> getRunners() {
    return Future.delayed(const Duration(seconds: 1), () => kRunners);
  }

  @override
  Future<List<GraphData>> getGraphData(String runSessionId) {
    final random = Random();
    return Future.delayed(
      const Duration(seconds: 100),
      () => [
        GraphData(
          title: 'Distance',
          yLabel: 'Distance(m)',
          yMin: 0,
          yMax: 100,
          x: List.generate(100, (_) {
            final value = random.nextDouble() * 15;
            return (value * 1000).round() / 1000;
          }),
          series: [
            GraphSeries(
              name: 'main',
              y: List.generate(100, (_) {
                final value = random.nextDouble() * 100;
                return (value * 1000).round() / 1000;
              }),
            ),
          ],
        ),
        GraphData(
          title: 'Velocity',
          yLabel: 'Velocity(m/s)',
          yMin: 0,
          yMax: 10,
          x: List.generate(100, (_) {
            final value = random.nextDouble() * 15;
            return (value * 1000).round() / 1000;
          }),
          series: [
            GraphSeries(
              name: 'main',
              y: List.generate(100, (_) {
                final value = random.nextDouble() * 10;
                return (value * 1000).round() / 1000;
              }),
            ),
          ],
        ),
        GraphData(
          title: 'Acceleration',
          yLabel: 'Acceleration(m/s^2)',
          yMin: -2,
          yMax: 5,
          x: List.generate(100, (_) {
            final value = random.nextDouble() * 15;
            return (value * 1000).round() / 1000;
          }),
          series: [
            GraphSeries(
              name: 'main',
              y: List.generate(100, (_) {
                final value = -2 + random.nextDouble() * 5;
                return (value * 1000).round() / 1000;
              }),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<RunSessionInfo> getRunSessionInfo(String runSessionId) {
    return Future.delayed(
      const Duration(seconds: 100),
      () => kVideos.firstWhere((video) => video.runSessionId == runSessionId),
    );
  }

  @override
  Future<List<RunSessionInfo>> getRunnerHistory(String runnerId) {
    return Future.delayed(
      const Duration(seconds: 100),
      () => kVideos.where((video) => video.runnerId == runnerId).toList(),
    );
  }

  @override
  Future<String> uploadVideo(int index, UploadVideoFile file) {
    return Future.delayed(
      const Duration(seconds: 100),
      () => 'https://catslab.ee.ncku.edu.tw:9125/images/placeholder.jpg',
    );
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
    final videoId = 'videoId${kVideos.length}';
    kVideos.add(
      RunSessionInfo(
        runSessionId: videoId,
        runnerId: runnerId,
        runnerName: kRunners.firstWhere((runner) => runner.id == runnerId).name,
        date: date,
        cameraCount: cameraCount,
        fps: fps,
        avgVelocity: 0,
        totalTime: 0,
        note: note,
        status: 'done',
        progress: 100,
      ),
    );
    return Future.delayed(const Duration(seconds: 1), () => videoId);
  }

  @override
  Future<List<UnanalyzedRunSessionInfo>> getRunnerUnanalyzedHistory(
    String runnerId,
  ) {
    return Future.delayed(
      const Duration(seconds: 100),
      () => [
        UnanalyzedRunSessionInfo(
          runSessionId: 'videoId0',
          runnerId: runnerId,
          runnerName: 'runnerName1',
          date: DateTime.parse('2025-12-27 10:00:00'),
          cameraCount: 5,
          fps: 60,
          note: 'note',
          unuploadedCameraIndexes: [0, 4],
          videoPaths: ['videoPath0', 'videoPath1'],
        ),
        UnanalyzedRunSessionInfo(
          runSessionId: 'videoId1',
          runnerId: runnerId,
          runnerName: 'runnerName1',
          date: DateTime.parse('2025-10-27 10:04:00'),
          cameraCount: 5,
          fps: 60,
          note: 'note',
          unuploadedCameraIndexes: [1, 4],
          videoPaths: ['videoPath0', 'videoPath1'],
        ),
      ],
    );
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
  ) {
    return Future.delayed(
      const Duration(seconds: 1),
      () => UploadSeperatelyStatus(
        runnerId: runnerId,
        runSessionId: 'videoId1',
        isAllUploaded: false,
        unuploadedCameraIndexes: [0, 4],
      ),
    );
  }

  @override
  Future<UploadSeperatelyStatus> uploadSeperatelySelect(
    String runnerId,
    String runSessionId,
    int cameraIndex,
    String tempVideoId,
    AnchorResult? anchors,
  ) {
    return Future.delayed(
      const Duration(seconds: 1),
      () => UploadSeperatelyStatus(
        runnerId: runnerId,
        runSessionId: runSessionId,
        isAllUploaded: true,
        unuploadedCameraIndexes: [],
      ),
    );
  }

  @override
  Future<String> addRunner(String name) {
    final runnerId = 'runnerId${kRunners.length}';
    kRunners.add(RunnerInfo(id: runnerId, name: name, lastVideoId: ''));
    return Future.delayed(const Duration(seconds: 1), () => runnerId);
  }

  @override
  Future<List<int>> getRunSessionPdf(String runSessionId) {
    return Future.value([]);
  }

  @override
  Future<List<int>> getRunSessionCsv(String runSessionId) {
    return Future.value([]);
  }

  @override
  Future<void> deleteRunSession(String runSessionId) {
    kVideos.removeWhere((video) => video.runSessionId == runSessionId);
    return Future.value();
  }

  @override
  Future<void> deleteRunner(String runnerId) {
    kRunners.removeWhere((runner) => runner.id == runnerId);
    kVideos.removeWhere((video) => video.runnerId == runnerId);
    return Future.value();
  }

  @override
  Future<StepsData> getRunSessionSteps(String runSessionId) {
    return Future.delayed(
      const Duration(seconds: 1),
      () => StepsData(steps: const []),
    );
  }

  @override
  Future<ToePathData> getRunSessionToePath(String runSessionId) {
    return Future.delayed(
      const Duration(seconds: 1),
      () => ToePathData(
        keypointNames: const [],
        hasWorldCoords: false,
        frames: const [],
      ),
    );
  }

  @override
  Future<List<int>> getTopdownReviewCameraIndices(String runSessionId) {
    return Future.value(const []);
  }
}
