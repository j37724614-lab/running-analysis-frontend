import 'package:frontend/feature/upload/local_video_stager.dart';
import 'package:frontend/feature/upload/local_video_stager_stub.dart'
    if (dart.library.io) 'package:frontend/feature/upload/local_video_stager_io.dart'
    as platform;

LocalVideoStager createLocalVideoStager() => platform.createPlatformLocalVideoStager();
