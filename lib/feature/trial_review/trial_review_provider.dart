import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/step_data.dart';
import 'package:frontend/entities/toe_path_data.dart';
import 'package:frontend/feature/trial_review/widget/trial_video_controller.dart';
import 'package:frontend/utils/api_retry.dart';

final trialReviewSelectedRunnerIdProvider = StateProvider<String?>((ref) => null);

final trialReviewSelectedRunSessionIdProvider = StateProvider<String?>((ref) => null);

/// Run session ids selected for multi-trial comparison (in addition to the
/// currently open trial above).
final trialReviewComparisonIdsProvider = StateProvider<Set<String>>((ref) => {});

/// The metrics-panel chart cards a user can individually show/hide (see
/// `MetricsPanel` and `ChartVisibilityMenuButton`). Order here is also the
/// display order when all are enabled.
enum MetricsChartType {
  stepLengthFrequency('①步幅＋步頻'),
  stepLateralPath('②同步腳步俯視路徑'),
  multiTrialStepLength('③多次試跳步幅比較');

  const MetricsChartType(this.label);
  final String label;
}

/// Which chart cards are currently shown in the metrics panel. Defaults to
/// all of them; users narrow this down via ChartVisibilityMenuButton so a
/// long parameter list stays a single scroll instead of needing pagination.
final trialReviewVisibleChartsProvider = StateProvider<Set<MetricsChartType>>(
  (ref) => MetricsChartType.values.toSet(),
);

final trialReviewStepsProvider = FutureProvider.autoDispose.family<StepsData, String>((
  ref,
  runSessionId,
) {
  final backend = ref.watch(backendProvider);
  return backend.getRunSessionSteps(runSessionId);
}, retry: apiRetry);

final trialReviewToePathProvider = FutureProvider.autoDispose.family<ToePathData, String>((
  ref,
  runSessionId,
) {
  final backend = ref.watch(backendProvider);
  return backend.getRunSessionToePath(runSessionId);
}, retry: apiRetry);

final topdownReviewCameraIndicesProvider = FutureProvider.autoDispose.family<List<int>, String>((
  ref,
  runSessionId,
) {
  final backend = ref.watch(backendProvider);
  return backend.getTopdownReviewCameraIndices(runSessionId);
}, retry: apiRetry);

final trialVideoControllerProvider = FutureProvider.autoDispose
    .family<TrialVideoPlaybackController, String>((ref, runSessionId) async {
      final info = await ref.watch(videoInfoProvider(runSessionId).future);
      final controller = await TrialVideoPlaybackController.create(
        runSessionId,
        info.cameraCount,
        ref: ref,
      );
      ref.onDispose(controller.dispose);
      return controller;
    }, retry: apiRetry);

/// `stepIndex` is now numbered globally across the whole trial (pipeline
/// side, see ankle_step_stride.py's step_index assignment), so it no longer
/// resets per camera. `timeSec` still resets near 0 at the start of each
/// camera's own clip, so it alone is not comparable across cameras. Cameras
/// are laid out sequentially along the runway (cam 0 = start, increasing
/// towards the board), so this sort (cam ascending, then `stepIndex`
/// ascending within a camera) matches true chronological order -- and is
/// equivalent to sorting by `stepIndex` alone now that it's global, but kept
/// explicit here in case that ever changes.
///
/// Assumes the last camera's last detected step is the board step -- true as
/// long as the camera keeps recording through take-off. Verify against a
/// real long-jump clip once available; if the recording is cut short before
/// the board, this will need to account for that instead.
List<StepSample> chronologicalSteps(StepsData data) {
  final steps = [...data.steps]
    ..sort((a, b) {
      final camCompare = a.cam.compareTo(b.cam);
      return camCompare != 0 ? camCompare : a.stepIndex.compareTo(b.stepIndex);
    });
  return steps;
}

/// Returns the cumulative footsteps that should be visible at the current
/// camera playback position. Completed earlier cameras remain on the runway;
/// the active camera reveals each landing when its video reaches [timeSec].
List<StepSample> visibleStepsAtPlayback(
  StepsData data, {
  required int activeCameraIndex,
  required Duration position,
}) {
  final positionSec = position.inMicroseconds / Duration.microsecondsPerSecond;
  return chronologicalSteps(data).where((step) {
    if (step.cam < activeCameraIndex) return true;
    if (step.cam > activeCameraIndex) return false;
    return step.timeSec <= positionSec;
  }).toList();
}

int stepRank(List<StepSample> chronological, int stepIndex) {
  final pos = chronological.indexWhere((s) => s.stepIndex == stepIndex);
  return pos < 0 ? 0 : pos + 1;
}

/// The trial's official jump distance: `stepLengthM` on the terminal
/// camera's `final_landing` event, i.e. board step -> sand landing point.
/// Null for non-long-jump trials, or long-jump trials where landing
/// detection didn't fire (see `long_jump_final_landing` pipeline config).
double? jumpDistanceM(StepsData data) {
  for (final step in data.steps) {
    if (step.eventType == 'final_landing') return step.stepLengthM;
  }
  return null;
}

/// A fixed, distinct palette so a trial keeps the same color across the
/// legend, the comparison-picker checkboxes, and every chart it appears on
/// within one page load.
const _kTrialPalette = [
  Colors.blue,
  Colors.deepOrange,
  Colors.green,
  Colors.purple,
  Colors.teal,
  Colors.brown,
  Colors.pink,
  Colors.indigo,
];

Map<String, Color> assignTrialColors(List<String> trialIds) {
  return {
    for (var i = 0; i < trialIds.length; i++)
      trialIds[i]: _kTrialPalette[i % _kTrialPalette.length],
  };
}
