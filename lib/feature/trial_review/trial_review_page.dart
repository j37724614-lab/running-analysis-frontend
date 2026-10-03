import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/runner_info.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/feature/trial_review/widget/current_trial_summary_header.dart';
import 'package:frontend/feature/trial_review/widget/metrics_panel.dart';
import 'package:frontend/feature/trial_review/widget/trial_history_view.dart';
import 'package:frontend/feature/trial_review/widget/triple_video_panel.dart';
import 'package:frontend/feature/trial_review/widget/topdown_review_panel.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/widget/async_value_widget.dart';

class TrialReviewPage extends ConsumerStatefulWidget {
  const TrialReviewPage({super.key, this.runnerId, this.videoId});

  final String? runnerId;
  final String? videoId;

  @override
  ConsumerState<TrialReviewPage> createState() => _TrialReviewPageState();
}

class _TrialReviewPageState extends ConsumerState<TrialReviewPage> {
  bool _isSidebarExpanded = true;

  void _retryTrialReview() {
    final selectedRunSessionId = ref.read(trialReviewSelectedRunSessionIdProvider);
    final comparisonIds = ref.read(trialReviewComparisonIdsProvider);
    final runSessionIds = <String>{
      if (selectedRunSessionId != null && selectedRunSessionId.isNotEmpty) selectedRunSessionId,
      ...comparisonIds,
    };

    ref.invalidate(runnerProvider);
    final runnerId = ref.read(trialReviewSelectedRunnerIdProvider);
    if (runnerId != null) ref.invalidate(runnerHistoryProvider(runnerId));

    for (final runSessionId in runSessionIds) {
      ref.invalidate(videoInfoProvider(runSessionId));
      ref.invalidate(trialReviewStepsProvider(runSessionId));
      ref.invalidate(trialReviewToePathProvider(runSessionId));
      ref.invalidate(topdownReviewCameraIndicesProvider(runSessionId));
      ref.invalidate(trialVideoControllerProvider(runSessionId));
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.runnerId != null && widget.videoId != null) {
        ref.read(trialReviewSelectedRunSessionIdProvider.notifier).state = widget.videoId;
        ref.read(trialReviewSelectedRunnerIdProvider.notifier).state = widget.runnerId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final runners = ref.watch(runnerProvider);
    final selectedRunnerId = ref.watch(trialReviewSelectedRunnerIdProvider);
    final selectedRunSessionId = ref.watch(trialReviewSelectedRunSessionIdProvider);
    final runnerSelector = AsyncValueWidget(
      value: runners,
      loading: const SizedBox(
        height: 50,
        width: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      data: (List<RunnerInfo> items) {
        return DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: false,
            hint: const Text('選擇選手'),
            items: items
                .map((item) => DropdownMenuItem<String>(value: item.id, child: Text(item.name)))
                .toList(),
            value: selectedRunnerId,
            onChanged: (value) {
              ref.read(trialReviewSelectedRunnerIdProvider.notifier).state = value;
              ref.read(trialReviewSelectedRunSessionIdProvider.notifier).state = items
                  .firstWhere((item) => item.id == value)
                  .lastVideoId;
            },
            buttonStyleData: ButtonStyleData(
              height: 50,
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26),
              ),
            ),
          ),
        );
      },
    );
    final runnerControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        runnerSelector,
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: '重新載入賽事資料',
          onPressed: _retryTrialReview,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );

    final body = Expanded(
      child: selectedRunSessionId == null || selectedRunSessionId.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '請先選擇選手與試跳紀錄',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  // Fewer than 3 cameras don't need the video panel's
                  // full flex:3 height share on narrow screens -- see
                  // TripleVideoPanel's matching "< 3 cameras" case. Only
                  // known once videoInfoProvider resolves; the flex:3
                  // split is used as the safe default until then.
                  final cameraCount = ref
                      .watch(videoInfoProvider(selectedRunSessionId))
                      .value
                      ?.cameraCount;
                  final isCompact = cameraCount != null && cameraCount < 3;
                  final videoPanel = TripleVideoPanel(
                    key: ValueKey('video-$selectedRunSessionId'),
                    runSessionId: selectedRunSessionId,
                  );
                  final metricsPanel = MetricsPanel(
                    key: ValueKey('metrics-$selectedRunSessionId'),
                    runSessionId: selectedRunSessionId,
                  );
                  final metricsWorkspace = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top-down replay is optional and opens in a dialog,
                      // so it never displaces CAM1–CAM3.
                      TopdownReviewPanel(
                        key: ValueKey('topdown-$selectedRunSessionId'),
                        runSessionId: selectedRunSessionId,
                      ),
                      Expanded(
                        child: Scrollbar(child: SingleChildScrollView(child: metricsPanel)),
                      ),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 4, child: videoPanel),
                        const SizedBox(width: 16),
                        Expanded(flex: 5, child: metricsWorkspace),
                      ],
                    );
                  }

                  // On narrow screens both work areas remain bounded by
                  // the viewport; the camera stack gets priority when
                  // there's a full 3 cameras to fit. Fewer than that
                  // doesn't need the reserved height (see
                  // TripleVideoPanel/SingleCameraPanel), so let it size
                  // to its own content and hand the rest to metrics.
                  return isCompact
                      ? Column(
                          children: [
                            videoPanel,
                            const SizedBox(height: 12),
                            Expanded(child: metricsWorkspace),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(flex: 3, child: videoPanel),
                            const SizedBox(height: 12),
                            Expanded(flex: 2, child: metricsWorkspace),
                          ],
                        );
                },
              ),
            ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final summary = selectedRunSessionId == null || selectedRunSessionId.isEmpty
            ? null
            : CurrentTrialSummaryHeader(
                key: ValueKey('summary-$selectedRunSessionId'),
                runSessionId: selectedRunSessionId,
              );

        final sidebarToggle = IconButton(
          icon: Icon(
            _isSidebarExpanded
                ? Icons.keyboard_double_arrow_left
                : Icons.keyboard_double_arrow_right,
          ),
          onPressed: () {
            setState(() => _isSidebarExpanded = !_isSidebarExpanded);
          },
          tooltip: _isSidebarExpanded ? l10n.close : l10n.analysisHistory,
        );

        final header = Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: isWide
              ? Row(
                  children: [
                    sidebarToggle,
                    const SizedBox(width: 4),
                    Expanded(flex: 4, child: Center(child: runnerControls)),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: summary ?? const SizedBox.shrink()),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    runnerControls,
                    const SizedBox(height: 8),
                    _buildMobileHistoryTrigger(context, l10n),
                    if (summary != null) ...[const SizedBox(height: 8), summary],
                  ],
                ),
        );

        if (!isWide) {
          return Column(children: [header, body]);
        }

        return Column(
          children: [
            header,
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: _isSidebarExpanded ? 280 : 0,
                    margin: EdgeInsets.only(
                      left: _isSidebarExpanded ? 12 : 0,
                      right: _isSidebarExpanded ? 4 : 0,
                      bottom: _isSidebarExpanded ? 12 : 0,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: _isSidebarExpanded
                          ? Border.all(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: SizedBox(
                      width: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                            child: Text(
                              l10n.analysisHistory,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const Expanded(child: TrialHistoryView()),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileHistoryTrigger(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: const EdgeInsets.only(top: 16),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      l10n.analysisHistory,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: TrialHistoryView(onSessionSelected: () => Navigator.of(context).pop()),
                  ),
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.history, size: 18, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.analysisHistory,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(
                Icons.arrow_drop_down_circle_outlined,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
