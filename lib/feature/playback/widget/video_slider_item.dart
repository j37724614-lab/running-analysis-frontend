import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/video_playback_state_provider.dart';

class VideoSliderView extends ConsumerWidget {
  final void Function(int position) onSeek;
  final Color? color;

  const VideoSliderView({super.key, required this.onSeek, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(videoPlaybackStateProvider).duration;
    final position = ref.watch(videoPlaybackStateProvider).position;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        color: color ?? Theme.of(context).primaryColor,
      ),
      child: Slider(
        min: 0,
        max: duration.toDouble(),
        value: position.toDouble(),
        thumbColor: Theme.of(context).primaryColorDark,
        activeColor: Theme.of(context).primaryColorDark,
        inactiveColor: Colors.white,
        onChangeStart: (_) {
          ref.read(videoPlaybackStateProvider.notifier).setDragging(true);
        },
        onChanged: (value) {
          ref.read(videoPlaybackStateProvider.notifier).setPosition(value.toInt());
        },
        onChangeEnd: (value) {
          ref.read(videoPlaybackStateProvider.notifier).setDragging(false);

          onSeek(value.toInt());
        },
      ),
    );
  }
}
