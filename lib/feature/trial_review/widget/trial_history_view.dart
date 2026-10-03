import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/run_session_info.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/feature/playback/shimmer/runner_history_shimmer.dart';
import 'package:frontend/feature/playback/placeholder/runner_history_placeholder.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

/// Lets the user browse this runner's past trials and pick which one is
/// shown as the page's primary video + metrics. Mirrors PlaybackPage's
/// `RunnerHistoryView` (same cards, colors, and status badges) so switching
/// between the two review pages feels the same; kept as its own widget
/// because it drives trial_review's own selected-session provider instead
/// of playback's. Distinct from `TrialSelectorView`, which only picks extra
/// trials to overlay on chart ③.
class TrialHistoryView extends ConsumerWidget {
  const TrialHistoryView({super.key, this.onSessionSelected});

  final VoidCallback? onSessionSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runnerId = ref.watch(trialReviewSelectedRunnerIdProvider);
    final videoId = ref.watch(trialReviewSelectedRunSessionIdProvider);
    final l10n = context.l10n;

    if (runnerId == null) {
      return const RunnerHistoryPlaceholder();
    }

    final runnerHistory = ref.watch(runnerHistoryProvider(runnerId));
    return AsyncValueWidget(
      value: runnerHistory,
      loading: const RunnerHistoryShimmer(),
      data: (List<RunSessionInfo> sessions) {
        if (sessions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_toggle_off_outlined, size: 32, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noHistoryFound,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final isSelected = session.runSessionId == videoId;

            Color badgeBgColor;
            Color badgeTextColor;
            String statusText;

            switch (session.status) {
              case 'done':
                badgeBgColor = Colors.green.shade50;
                badgeTextColor = Colors.green.shade700;
                statusText = l10n.statusDone;
                break;
              case 'failed':
                badgeBgColor = Colors.red.shade50;
                badgeTextColor = Colors.red.shade700;
                statusText = l10n.statusFailed;
                break;
              case 'processing':
                badgeBgColor = Colors.orange.shade50;
                badgeTextColor = Colors.orange.shade700;
                statusText = l10n.statusProcessing;
                break;
              default:
                badgeBgColor = Colors.grey.shade100;
                badgeTextColor = Colors.grey.shade700;
                statusText = session.status;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColorDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColorDark
                        : Theme.of(context).primaryColor.withValues(alpha: 0.4),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      if (session.status == 'failed') {
                        toastification.show(
                          context: context,
                          title: Text(
                            l10n.analysisFailedTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          description: Text(l10n.analysisFailedDescription),
                          type: ToastificationType.error,
                          style: ToastificationStyle.minimal,
                          alignment: Alignment.bottomCenter,
                          autoCloseDuration: const Duration(seconds: 4),
                        );
                      }
                      ref.read(trialReviewSelectedRunSessionIdProvider.notifier).state =
                          session.runSessionId;

                      onSessionSelected?.call();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Theme.of(context).primaryColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.directions_run,
                              color: isSelected ? Colors.white : Theme.of(context).primaryColorDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('yyyy-MM-dd HH:mm').format(session.date),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.videocam_outlined,
                                      size: 14,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${session.cameraCount} ${l10n.cameras}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.8)
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    if (session.status == 'processing') ...[
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isSelected ? Colors.white : Colors.orange.shade700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${session.progress}%",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected
                                              ? Colors.white.withValues(alpha: 0.9)
                                              : Colors.orange.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (session.note.trim().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    session.note,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : badgeBgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
