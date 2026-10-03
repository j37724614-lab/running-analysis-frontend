import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/entities/step_data.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/feature/trial_review/widget/multi_trial_step_length_chart.dart';
import 'package:frontend/feature/trial_review/widget/chart_visibility_menu_button.dart';
import 'package:frontend/feature/trial_review/widget/step_length_frequency_chart.dart';
import 'package:frontend/feature/trial_review/widget/step_lateral_path_chart.dart';
import 'package:frontend/feature/trial_review/widget/trial_selector_view.dart';
import 'package:frontend/feature/trial_review/widget/trial_review_error_view.dart';
import 'package:frontend/widget/async_value_widget.dart';

/// Right-side metrics panel: step length/frequency (①) and the top-down
/// step lateral-position path (②) for the currently open trial only, plus a
/// multi-trial step-length comparison chart (③) and a trial picker, driven
/// by trialReviewComparisonIdsProvider. Which of ①②③ actually render is
/// controlled by trialReviewVisibleChartsProvider (see
/// ChartVisibilityMenuButton) -- the panel already scrolls
/// (trial_review_page.dart wraps it in a SingleChildScrollView), so hiding
/// unwanted charts is how a long parameter list stays a single scroll
/// instead of needing pagination.
class MetricsPanel extends ConsumerWidget {
  final String runSessionId;

  const MetricsPanel({super.key, required this.runSessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepsAsync = ref.watch(trialReviewStepsProvider(runSessionId));
    final runnerId = ref.watch(trialReviewSelectedRunnerIdProvider);
    final comparisonIds = ref.watch(trialReviewComparisonIdsProvider);
    final visibleCharts = ref.watch(trialReviewVisibleChartsProvider);
    final playbackController = ref.watch(trialVideoControllerProvider(runSessionId)).value;

    if (stepsAsync.hasError) {
      return TrialReviewErrorView(
        error: stepsAsync.error!,
        onRetry: () => ref.invalidate(trialReviewStepsProvider(runSessionId)),
      );
    }

    final allTrialIds = [runSessionId, ...comparisonIds];
    final trialColors = assignTrialColors(allTrialIds);
    final trialLabels = {
      for (final id in allTrialIds) id: id == runSessionId ? '目前試跳' : id.substring(0, 8),
    };

    // Watch steps for every selected trial; charts render with whichever
    // have resolved so far rather than blocking on the slowest one.
    final trialSteps = <String, StepsData>{};
    for (final id in allTrialIds) {
      final value = ref.watch(trialReviewStepsProvider(id)).value;
      if (value != null) trialSteps[id] = value;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [ChartVisibilityMenuButton()],
        ),
        if (visibleCharts.contains(MetricsChartType.stepLengthFrequency)) ...[
          AsyncValueWidget(
            value: stepsAsync,
            loading: const _LoadingCard(),
            data: (StepsData steps) =>
                StepLengthFrequencyChart(runSessionId: runSessionId, data: steps),
          ),
          const SizedBox(height: 12),
        ],
        if (visibleCharts.contains(MetricsChartType.stepLateralPath)) ...[
          AsyncValueWidget(
            value: stepsAsync,
            loading: const _LoadingCard(),
            data: (StepsData steps) =>
                StepLateralPathChart(data: steps, playbackController: playbackController),
          ),
          const SizedBox(height: 12),
        ],
        if (visibleCharts.contains(MetricsChartType.multiTrialStepLength)) ...[
          MultiTrialStepLengthChart(
            currentRunSessionId: runSessionId,
            trials: trialSteps,
            trialColors: trialColors,
            trialLabels: trialLabels,
          ),
          const SizedBox(height: 12),
        ],
        if (runnerId != null)
          TrialSelectorView(runnerId: runnerId, currentRunSessionId: runSessionId),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const CircularProgressIndicator(),
    );
  }
}
