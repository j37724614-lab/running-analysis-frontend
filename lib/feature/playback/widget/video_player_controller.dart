import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/api.dart';
import 'package:frontend/utils/api_retry.dart';
import 'package:video_player/video_player.dart';

import 'package:frontend/feature/auth/auth_provider.dart';

class VideoControllerManager {
  late final VideoPlayerController controller;

  VideoControllerManager(String videoUrl) {
    controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
  }

  Future<void> initializeAll() async {
    await controller.initialize();
    await controller.seekTo(Duration.zero);
  }

  void play() {
    controller.play();
  }

  void pause() {
    controller.pause();
  }

  void dispose() {
    controller.dispose();
  }

  void seek(Duration position) {
    controller.seekTo(position);
  }
}

final videoManagerProvider =
    FutureProvider.family<VideoControllerManager, String>((ref, id) async {
      final authState = ref.watch(authProvider);
      final token = authState.token;
      var urls = API.getRunSessionVideo(id)[1] as String;
      if (token != null && token.isNotEmpty) {
        final separator = urls.contains('?') ? '&' : '?';
        urls = '$urls${separator}token=$token';
      }

      final manager = VideoControllerManager(urls);
      try {
        await manager.initializeAll();
        ref.onDispose(manager.dispose);
        return manager;
      } catch (_) {
        manager.dispose();
        rethrow;
      }
    }, retry: apiRetry);
