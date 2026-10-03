import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/entities/step_data.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:video_player/video_player.dart';

/// Bridges the playing video's current position to "which chronological
/// step rank is this" for a chart, so ① and ③ can draw a cursor that tracks
/// CAM1-3 playback instead of the charts and video being two disconnected
/// views. Feeds `builder` a rank whenever it's known and null otherwise
/// (video not initialized yet, or no step in this camera's clip).
///
/// Reactivity is two-layered on purpose: TrialVideoPlaybackController is a
/// ChangeNotifier that only fires on discrete events (play/pause/camera
/// switch), so it's listened to via AnimatedBuilder like TripleVideoPanel
/// does; the active camera's own VideoPlayerController fires on every
/// position tick, so it's listened to via ValueListenableBuilder like
/// _VideoSeekSlider does. Skipping the inner listener would leave the
/// cursor frozen between camera switches instead of tracking playback.
class PlaybackCursor extends ConsumerWidget {
  final String runSessionId;
  final StepsData data;
  final Widget Function(BuildContext context, int? stepRank) builder;

  const PlaybackCursor({
    super.key,
    required this.runSessionId,
    required this.data,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(trialVideoControllerProvider(runSessionId)).value;
    if (controller == null || controller.managers.isEmpty) {
      return builder(context, null);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final activeIndex = controller.activeIndex;
        final activeController = controller.managers[activeIndex].controller;
        return ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: activeController,
          builder: (context, value, _) {
            return builder(context, _stepRankFor(activeIndex, value.position));
          },
        );
      },
    );
  }

  int? _stepRankFor(int activeCam, Duration position) {
    final posSec = position.inMilliseconds / 1000.0;
    final chronological = chronologicalSteps(data);
    final sameCam = chronological.where((s) => s.cam == activeCam).toList();
    if (sameCam.isEmpty) return null;
    var closest = sameCam.first;
    var bestDiff = (closest.timeSec - posSec).abs();
    for (final step in sameCam.skip(1)) {
      final diff = (step.timeSec - posSec).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        closest = step;
      }
    }
    return stepRank(chronological, closest.stepIndex);
  }
}
