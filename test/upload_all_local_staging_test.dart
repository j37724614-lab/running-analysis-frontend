import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/backend/fake_backend_repo.dart';
import 'package:frontend/feature/upload/widget/upload_all_controller.dart';

void main() {
  test('Local selection stores only a path and does not create a server temp video', () {
    final controller = UploadAllController(FakeBackendRepo(), null);
    controller.setCameraCount(1);

    controller.stageLocalVideo(0, path: '/tmp/input.mov', filename: 'input.mov');

    final selected = controller.state.tempVideoStates.single;
    expect(selected.localPath, '/tmp/input.mov');
    expect(selected.filename, 'input.mov');
    expect(selected.tempVideoId, isNull);
    expect(selected.uploadFile, isNull);
    expect(selected.isSelected, isTrue);
  });

  test('clearing staged videos prevents a Server/Local mode switch from reusing data', () {
    final controller = UploadAllController(FakeBackendRepo(), null);
    controller.setCameraCount(1);
    controller.stageLocalVideo(0, path: '/tmp/input.mov', filename: 'input.mov');

    controller.clearVideos();

    expect(controller.state.tempVideoStates.single.isSelected, isFalse);
  });
}
