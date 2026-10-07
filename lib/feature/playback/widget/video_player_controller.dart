import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/api.dart';
import 'package:video_player/video_player.dart';

import 'package:frontend/feature/auth/auth_provider.dart';

Duration? videoPlaybackRetry(int retryCount, Object error) {
  final message = error.toString().toLowerCase();
  if (message.contains('404') ||
      message.contains('not found') ||
      message.contains('-1100') ||
      retryCount >= 3) {
    return null;
  }
  const delays = [Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 4)];
  return delays[retryCount];
}

String videoPlaybackErrorMessage(Object error) {
  final message = error.toString().toLowerCase();
  if (message.contains('404') || message.contains('not found') || message.contains('-1100')) {
    return '伺服器找不到這次分析的影片，請重新同步 Local 分析結果。';
  }
  return '影片載入失敗，已停止自動重試。請檢查網路後再試一次。';
}

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

final videoManagerProvider = FutureProvider.family<VideoControllerManager, String>((ref, id) async {
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
}, retry: videoPlaybackRetry);
