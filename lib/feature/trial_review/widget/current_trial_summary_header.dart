import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:intl/intl.dart';

/// Compact "which trial am I looking at" summary shown next to the runner
/// selector: date, average step length/cadence, and (for long-jump trials)
/// the official jump distance.
class CurrentTrialSummaryHeader extends ConsumerWidget {
  final String runSessionId;

  const CurrentTrialSummaryHeader({super.key, required this.runSessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(videoInfoProvider(runSessionId));
    final stepsAsync = ref.watch(trialReviewStepsProvider(runSessionId));

    final info = infoAsync.value;
    final steps = stepsAsync.value;
    if (info == null) return const SizedBox.shrink();

    final distance = steps == null ? null : jumpDistanceM(steps);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '${info.runnerName} · ${DateFormat('yyyy/MM/dd HH:mm').format(info.date)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (info.avgStepLength != null)
            _stat('平均步幅', '${info.avgStepLength!.toStringAsFixed(2)} m'),
          if (steps?.avgCadenceSpm != null)
            _stat('平均步頻', '${steps!.avgCadenceSpm!.toStringAsFixed(0)} spm'),
          if (distance != null) _stat('跳遠距離', '${distance.toStringAsFixed(2)} m'),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Text('$label：$value', style: const TextStyle(fontSize: 13, color: Colors.black87));
  }
}
