import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/backend/fake_backend_repo.dart';
import 'package:frontend/feature/upload/local_video_stager_io.dart';
import 'package:frontend/feature/upload/widget/upload_all_controller.dart';

void main() {
  test('Local selection stores a durable copy instead of the picker temporary path', () async {
    final sandbox = await Directory.systemTemp.createTemp('local-video-staging-test-');
    addTearDown(() => sandbox.delete(recursive: true));
    final pickerDirectory = Directory('${sandbox.path}/picker')..createSync();
    final stagingDirectory = Directory('${sandbox.path}/application-support');
    final source = File('${pickerDirectory.path}/input.mov')..writeAsStringSync('video-bytes');
    final controller = UploadAllController(
      FakeBackendRepo(),
      null,
      localVideoStager: IoLocalVideoStager(rootDirectory: () async => stagingDirectory),
    );
    controller.setCameraCount(1);

    await controller.stageLocalVideo(0, path: source.path, filename: 'input.mov');
    await source.delete();

    final selected = controller.state.tempVideoStates.single;
    expect(selected.localPath, isNot(source.path));
    expect(File(selected.localPath!).existsSync(), isTrue);
    expect(File(selected.localPath!).readAsStringSync(), 'video-bytes');
    expect(selected.filename, 'input.mov');
    expect(selected.tempVideoId, isNull);
    expect(selected.uploadFile, isNull);
    expect(selected.isSelected, isTrue);
  });

  test('clearing staged videos removes their durable copies', () async {
    final sandbox = await Directory.systemTemp.createTemp('local-video-clear-test-');
    addTearDown(() => sandbox.delete(recursive: true));
    final source = File('${sandbox.path}/input.mov')..writeAsStringSync('video-bytes');
    final stagingDirectory = Directory('${sandbox.path}/application-support');
    final controller = UploadAllController(
      FakeBackendRepo(),
      null,
      localVideoStager: IoLocalVideoStager(rootDirectory: () async => stagingDirectory),
    );
    controller.setCameraCount(1);
    await controller.stageLocalVideo(0, path: source.path, filename: 'input.mov');
    final stagedPath = controller.state.tempVideoStates.single.localPath!;

    await controller.clearVideos();

    expect(controller.state.tempVideoStates.single.isSelected, isFalse);
    expect(File(stagedPath).existsSync(), isFalse);
  });
}
