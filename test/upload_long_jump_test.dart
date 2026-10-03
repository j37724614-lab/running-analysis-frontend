import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/backend/fake_backend_repo.dart';
import 'package:frontend/entities/upload_seperately_status.dart';
import 'package:frontend/feature/upload/upload_controller.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';

/// Records the long-jump flag that reaches the backend.
class _RecordingBackend extends FakeBackendRepo {
  final List<bool> uploadAllLongJump = [];
  final List<bool> uploadSeperatelyLongJump = [];

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
    uploadAllLongJump.add(isLongJump);
    return 'session-all';
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
    uploadSeperatelyLongJump.add(isLongJump);
    return UploadSeperatelyStatus(
      runnerId: runnerId,
      runSessionId: 'session-sep',
      unuploadedCameraIndexes: [1],
      isAllUploaded: false,
    );
  }
}

void main() {
  late _RecordingBackend backend;
  late UploadController controller;

  setUp(() {
    backend = _RecordingBackend();
    controller = UploadController(backend: backend, onUploadCompleted: (_, _) {});
  });

  tearDown(() => controller.dispose());

  for (final isLongJump in [true, false]) {
    test('upload-all forwards isLongJump=$isLongJump to the backend', () async {
      await controller.uploadAllInfo(
        'runner-1',
        DateTime(2026, 10, 3),
        const TimeOfDay(hour: 9, minute: 0),
        1,
        60,
        '',
        isLongJump,
        const [],
      );

      expect(backend.uploadAllLongJump, [isLongJump]);
    });

    test('upload-separately (new session) forwards isLongJump=$isLongJump', () async {
      await controller.uploadSeperatelyNew(
        'runner-1',
        DateTime(2026, 10, 3),
        const TimeOfDay(hour: 9, minute: 0),
        2,
        60,
        '',
        isLongJump,
        0,
        'temp-video-0',
        null,
      );

      expect(backend.uploadSeperatelyLongJump, [isLongJump]);
    });
  }
}
