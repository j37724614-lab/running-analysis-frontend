import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/unanalyzed_run_session_info.dart';
import 'package:frontend/feature/upload/upload_provider.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/feature/playback/shimmer/runner_history_shimmer.dart';
import 'package:intl/intl.dart';

class UnanalyzedHistoryView extends ConsumerWidget {
  const UnanalyzedHistoryView({super.key, required this.onVideoSelected});

  final Function(UnanalyzedRunSessionInfo video) onVideoSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final runnerId = ref.watch(uploadSelectedRunnerIdProvider);
    final videoId = ref.watch(uploadSelectedRunSessionIdProvider);

    if (runnerId == null) {
      return const _UnanalyzedHistoryPanelWrapper(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off_outlined, size: 28, color: Colors.grey),
              SizedBox(height: 6),
              Text(
                '請先選擇跑者',
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    final runnerHistory = ref.watch(runnerUnanalyzedHistoryProvider(runnerId));
    return AsyncValueWidget(
      value: runnerHistory,
      loading: const _UnanalyzedHistoryPanelWrapper(child: RunnerHistoryShimmer()),
      data: (List<UnanalyzedRunSessionInfo> videos) {
        if (videos.isEmpty) {
          return _UnanalyzedHistoryPanelWrapper(
            title: l10n.pleaseSelectRecordToUpload,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history_toggle_off_outlined, size: 28, color: Colors.grey),
                    const SizedBox(height: 6),
                    Text(
                      l10n.noUnanalyzedRecords,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _UnanalyzedHistoryPanelWrapper(
          title: l10n.pleaseSelectRecordToUpload,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final isSelected = video.runSessionId == videoId;
                  final missingCount = video.unuploadedCameraIndexes.length;
                  final missingCamerasStr = video.unuploadedCameraIndexes
                      .map((i) => "${i + 1}")
                      .join(', ');

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColorDark : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColorDark
                              : Theme.of(context).primaryColor.withValues(alpha: 0.35),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(9),
                          onTap: () {
                            ref.read(uploadSelectedRunSessionIdProvider.notifier).state =
                                video.runSessionId;
                            onVideoSelected(video);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              children: [
                                // Left Icon
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.directions_run,
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).primaryColorDark,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Middle Column: Combined Single Line Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Main Information Row (Date + Cameras + Missing Tag)
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 2,
                                        children: [
                                          Text(
                                            DateFormat('yyyy-MM-dd HH:mm').format(video.date),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: isSelected ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.videocam_outlined,
                                                size: 13,
                                                color: isSelected
                                                    ? Colors.white.withValues(alpha: 0.8)
                                                    : Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                "${video.cameraCount} ${l10n.cameras}",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isSelected
                                                      ? Colors.white.withValues(alpha: 0.8)
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (missingCount > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 1,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.white.withValues(alpha: 0.2)
                                                    : Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.white30
                                                      : Colors.orange.shade200,
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                "缺相機 $missingCamerasStr",
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.orange.shade800,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (video.note.trim().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          video.note,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10.5,
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
                                // Right Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    missingCount == 0 ? l10n.statusDone : "待補傳 ($missingCount)",
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.amber.shade800,
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
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UnanalyzedHistoryPanelWrapper extends StatelessWidget {
  final Widget child;
  final String? title;

  const _UnanalyzedHistoryPanelWrapper({required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth < 600 ? constraints.maxWidth : 500.0;
        return Container(
          width: panelWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  children: [
                    Icon(
                      Icons.pending_actions_rounded,
                      size: 16,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        title ?? l10n.uncompletedRecordsPlaceholder,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
              child,
            ],
          ),
        );
      },
    );
  }
}
