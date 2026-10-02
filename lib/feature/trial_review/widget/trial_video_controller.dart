import 'package:flutter/foundation.dart';
import 'package:frontend/feature/auth/auth_provider.dart';
import 'package:frontend/feature/playback/widget/video_player_controller.dart';
import 'package:frontend/utils/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlaybackMode { sequential, single }

/// Owns 3 [VideoControllerManager]s (one per camera) and orchestrates either
/// looping back-to-back "sequential" playback (cam0 -> cam1 -> cam2 -> cam0)
/// or playing a single camera's segment in isolation.
class TrialVideoPlaybackController extends ChangeNotifier {
  final String runSessionId;
  final List<VideoControllerManager> managers;

  PlaybackMode mode = PlaybackMode.single;
  int activeIndex = 0;

  TrialVideoPlaybackController({
    required this.runSessionId,
    required this.managers,
  }) {
    for (var i = 0; i < managers.length; i++) {
      managers[i].controller.addListener(() => _onTick(i));
    }
  }

  static Future<TrialVideoPlaybackController> create(
    String runSessionId,
    int cameraCount, {
    Ref? ref,
  }) async {
    final managers = <VideoControllerManager>[];
    for (var i = 0; i < cameraCount; i++) {
      var url = API.getRunSessionCameraVideo(runSessionId, i);
      // Same auth-token appending as video_player_controller.dart's
      // videoManagerProvider -- this URL is handed straight to
      // VideoPlayerController.networkUrl, bypassing NetUtils/Dio (which
      // attaches the token automatically for ordinary API calls).
      final token = ref?.read(authProvider).token;
      if (token != null && token.isNotEmpty) {
        final separator = url.contains('?') ? '&' : '?';
        url = '$url${separator}token=$token';
      }
      final manager = VideoControllerManager(url);
      try {
        await manager.initializeAll();
        managers.add(manager);
      } catch (_) {
        manager.dispose();
        for (final initializedManager in managers) {
          initializedManager.dispose();
        }
        rethrow;
      }
    }
    return TrialVideoPlaybackController(
      runSessionId: runSessionId,
      managers: managers,
    );
  }

  void _onTick(int index) {
    if (mode != PlaybackMode.sequential || index != activeIndex) return;
    final value = managers[index].controller.value;
    if (!value.isPlaying &&
        value.position >= value.duration &&
        value.duration > Duration.zero) {
      _advanceSequential();
    }
  }

  void _advanceSequential() {
    managers[activeIndex].pause();
    if (activeIndex + 1 >= managers.length) {
      // Keep the replay workspace running continuously: after CAM3, restart
      // CAM1 rather than leaving the final camera parked at its last frame.
      activeIndex = 0;
    } else {
      activeIndex += 1;
    }
    managers[activeIndex].seek(Duration.zero);
    managers[activeIndex].play();
    notifyListeners();
  }

  void playSequential() {
    mode = PlaybackMode.sequential;
    for (final manager in managers) {
      manager.pause();
    }
    activeIndex = 0;
    managers[0].seek(Duration.zero);
    managers[0].play();
    notifyListeners();
  }

  void playSingle(int cameraIndex) {
    mode = PlaybackMode.single;
    for (var i = 0; i < managers.length; i++) {
      if (i == cameraIndex) continue;
      managers[i].pause();
    }
    activeIndex = cameraIndex;
    managers[cameraIndex].play();
    notifyListeners();
  }

  void toggleSingle(int cameraIndex) {
    final manager = managers[cameraIndex];
    final wasPlaying = manager.controller.value.isPlaying;

    // An explicit per-camera action leaves sequential mode so pausing a
    // segment cannot automatically advance to the next camera.
    mode = PlaybackMode.single;
    for (var i = 0; i < managers.length; i++) {
      if (i != cameraIndex) managers[i].pause();
    }
    activeIndex = cameraIndex;

    if (wasPlaying) {
      manager.pause();
    } else {
      if (manager.controller.value.position >=
          manager.controller.value.duration) {
        manager.seek(Duration.zero);
      }
      manager.play();
    }
    notifyListeners();
  }

  void pauseAll() {
    for (final manager in managers) {
      manager.pause();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final manager in managers) {
      manager.dispose();
    }
    super.dispose();
  }
}
