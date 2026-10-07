import 'package:frontend/feature/upload/local_video_stager.dart';

LocalVideoStager createPlatformLocalVideoStager() => UnsupportedLocalVideoStager();

class UnsupportedLocalVideoStager implements LocalVideoStager {
  @override
  Future<String> stage({required String sourcePath, required String filename}) {
    throw UnsupportedError('Local analysis video staging is unavailable on this platform.');
  }

  @override
  Future<void> remove(String stagedPath) async {}
}
