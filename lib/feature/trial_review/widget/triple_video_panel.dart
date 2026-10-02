import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/feature/trial_review/widget/single_camera_panel.dart';
import 'package:frontend/feature/trial_review/widget/trial_video_controller.dart';
import 'package:frontend/feature/trial_review/widget/trial_review_error_view.dart';
import 'package:frontend/widget/async_value_widget.dart';

class TripleVideoPanel extends ConsumerWidget {
  final String runSessionId;

  const TripleVideoPanel({super.key, required this.runSessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerAsync = ref.watch(
      trialVideoControllerProvider(runSessionId),
    );

    return AsyncValueWidget(
      value: controllerAsync,
      loading: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => TrialReviewErrorView(
        error: error,
        onRetry: () =>
            ref.invalidate(trialVideoControllerProvider(runSessionId)),
      ),
      data: (controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Column(
              // Reports its own size as "sum of children" rather than
              // "fill the incoming height constraint" -- safe either way:
              // with 2-3 cameras the inner Expanded still consumes whatever
              // bounded height the parent gives it (min vs max report the
              // same final size once that Expanded has claimed the rest);
              // with a single camera there's no Expanded child at all, and
              // the parent may not bound height in the first place (see
              // trial_review_page.dart's single-camera branch), so
              // reporting "max" there would try to size to an unbounded
              // height and crash.
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.playSequential,
                        icon: const Icon(Icons.playlist_play),
                        label: const Text('依序循環'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: controller.pauseAll,
                      icon: const Icon(Icons.pause),
                      label: const Text('全部暫停'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(controller.managers.length, (i) {
                    final isCurrentSegment =
                        controller.mode == PlaybackMode.sequential &&
                        i == controller.activeIndex;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isCurrentSegment
                              ? Theme.of(context).primaryColor
                              : Colors.black12,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // The flat crop ratio was tuned so that a *full* 3-camera
                // stack just fits its allotted height (that's the whole
                // reason it's so flat -- see single_camera_panel.dart).
                // Every camera needs the same natural height for a given
                // width regardless of how many there are, so with fewer
                // than 3 cameras that same per-camera height was already
                // proven to fit -- no need to stretch/divide the allotted
                // height evenly and paint extra black background around
                // what's left over. Only the full 3-camera case still needs
                // to stretch-and-shrink-to-fit, since that's the one
                // configuration the height budget is actually tight for.
                if (controller.managers.length < 3)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(controller.managers.length, (i) {
                      return Padding(
                        padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
                        child: SingleCameraPanel(
                          cameraIndex: i,
                          manager: controller.managers[i],
                          isActive:
                              i == controller.activeIndex &&
                              controller.managers[i].controller.value.isPlaying,
                          onTogglePlayback: () => controller.toggleSingle(i),
                          fillAvailableHeight: false,
                        ),
                      );
                    }),
                  )
                else
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(controller.managers.length, (i) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
                            child: SingleCameraPanel(
                              cameraIndex: i,
                              manager: controller.managers[i],
                              isActive:
                                  i == controller.activeIndex &&
                                  controller
                                      .managers[i]
                                      .controller
                                      .value
                                      .isPlaying,
                              onTogglePlayback: () =>
                                  controller.toggleSingle(i),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
