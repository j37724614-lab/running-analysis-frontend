import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/run_session_info.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:intl/intl.dart';

/// Lets the user pick past trials of the same runner to overlay onto the
/// ③ multi-trial comparison chart. The currently open trial is always
/// included and isn't offered as a checkbox here.
class TrialSelectorView extends ConsumerWidget {
  final String runnerId;
  final String currentRunSessionId;

  const TrialSelectorView({super.key, required this.runnerId, required this.currentRunSessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(runnerHistoryProvider(runnerId));
    final comparisonIds = ref.watch(trialReviewComparisonIdsProvider);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('比較其他試跳', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          AsyncValueWidget(
            value: historyAsync,
            loading: const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
            data: (List<RunSessionInfo> history) {
              final others = history.where((s) => s.runSessionId != currentRunSessionId).toList();
              if (others.isEmpty) {
                return const Text(
                  '沒有其他可比較的試跳',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final session in others)
                    FilterChip(
                      label: Text(DateFormat('MM/dd HH:mm').format(session.date)),
                      selected: comparisonIds.contains(session.runSessionId),
                      onSelected: (selected) {
                        final next = Set<String>.from(comparisonIds);
                        if (selected) {
                          next.add(session.runSessionId);
                        } else {
                          next.remove(session.runSessionId);
                        }
                        ref.read(trialReviewComparisonIdsProvider.notifier).state = next;
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
