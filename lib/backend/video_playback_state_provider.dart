import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/entities/video_playback.dart';

class VideoPlaybackNotifierState extends StateNotifier<VideoPlayback> {
  VideoPlaybackNotifierState() : super(VideoPlayback.initial);

  void setResult(VideoPlayback result) {
    state = result;
  }

  void setDragging(bool dragging) {
    state = state.copyWith(isDragging: dragging);
  }

  void setPosition(int position) {
    state = state.copyWith(position: position);
  }

  void setDuration(int duration) {
    state = state.copyWith(duration: duration);
  }

  void setCurrentFrame(int currentFrame) {
    state = state.copyWith(currentFrame: currentFrame);
  }

  int get position => state.position;
  int get duration => state.duration;
  int get currentFrame => state.currentFrame;
}

final videoPlaybackStateProvider =
    StateNotifierProvider.autoDispose<VideoPlaybackNotifierState, VideoPlayback>(
      (ref) => VideoPlaybackNotifierState(),
    );
