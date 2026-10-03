import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/runner_info.dart';
import 'package:frontend/entities/run_session_info.dart';
import 'package:frontend/feature/guide/guide_steps_factory.dart';
import 'package:frontend/feature/guide/guide_tour_service.dart';
import 'package:frontend/feature/playback/playback_provider.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/feature/playback/widget/video_player_view.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/feature/playback/widget/graph_list_view.dart';
import 'package:frontend/feature/playback/widget/runner_history_view.dart';
import 'package:frontend/feature/playback/widget/video_info_view.dart';
import 'package:frontend/feature/playback/widget/session_actions_view.dart';
import 'package:frontend/widget/rounded_box_widget.dart';
import 'package:frontend/feature/playback/shimmer/runner_dropdown_shimmer.dart';
import 'package:intl/intl.dart';

class PlaybackPage extends ConsumerStatefulWidget {
  const PlaybackPage({super.key, this.runnerId, this.videoId});

  final String? runnerId;
  final String? videoId;

  @override
  ConsumerState<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends ConsumerState<PlaybackPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (widget.runnerId != null && widget.videoId != null) {
        ref.read(playbackSelectedRunSessionIdProvider.notifier).state = widget.videoId;
        ref.read(playbackSelectedRunnerIdProvider.notifier).state = widget.runnerId;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          GuideTourService.startTour(
            context: context,
            tourKey: GuideTourService.tourPlayback,
            steps: GuideStepsFactory.getPlaybackSteps(context, ref),
            force: false,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final runners = ref.watch(runnerProvider);
    final selectedRunnerId = ref.watch(playbackSelectedRunnerIdProvider);
    final selectedVideoId = ref.watch(playbackSelectedRunSessionIdProvider);
    final isSidebarExpanded = ref.watch(playbackSidebarExpandedProvider);

    // Validate runner ID against the runner list when loaded
    final activeRunnerId = runners.when(
      data: (items) {
        final isRunnerIdValid = items.any((r) => r.id == selectedRunnerId);
        if (!isRunnerIdValid && selectedRunnerId != null && selectedRunnerId.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.read(playbackSelectedRunnerIdProvider.notifier).state = items.isNotEmpty
                ? items.first.id
                : null;
            ref.read(playbackSelectedRunSessionIdProvider.notifier).state = items.isNotEmpty
                ? items.first.lastVideoId
                : null;
            context.go('/playback');
          });
          return items.isNotEmpty ? items.first.id : null;
        }
        return selectedRunnerId;
      },
      error: (_, __) => null,
      loading: () => null,
    );

    // Validate video ID against the runner's history list when loaded
    if (activeRunnerId != null) {
      ref.watch(runnerHistoryProvider(activeRunnerId)).whenData((history) {
        if (selectedVideoId != null && selectedVideoId.isNotEmpty) {
          if (!history.any((s) => s.runSessionId == selectedVideoId)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ref.read(playbackSelectedRunSessionIdProvider.notifier).state = history.isNotEmpty
                  ? history.last.runSessionId
                  : null;
              context.go('/playback');
            });
          }
        }
      });
    }

    final selectedRunnerName =
        runners.whenOrNull(
          data: (items) => items
              .firstWhere(
                (runner) => runner.id == activeRunnerId,
                orElse: () => RunnerInfo(id: '', name: '', lastVideoId: ''),
              )
              .name,
        ) ??
        '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 900;

        if (isLargeScreen) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unified Top Row (Seamless Background)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 4),
                child: Row(
                  children: [
                    // Sidebar Expand/Collapse Toggle Button
                    IconButton(
                      key: GuideKeys.playbackSidebarToggleKey,
                      icon: Icon(
                        isSidebarExpanded
                            ? Icons.keyboard_double_arrow_left
                            : Icons.keyboard_double_arrow_right,
                      ),
                      onPressed: () {
                        ref.read(playbackSidebarExpandedProvider.notifier).state =
                            !isSidebarExpanded;
                      },
                      tooltip: isSidebarExpanded ? l10n.close : l10n.analysisHistory,
                    ),
                    const SizedBox(width: 8),
                    // Runner Selector
                    Expanded(
                      key: GuideKeys.playbackRunnerKey,
                      child: AsyncValueWidget(
                        value: runners,
                        loading: const RunnerDropdownShimmer(),
                        data: (List<RunnerInfo> items) => _buildRunnerDropdown(
                          context,
                          items,
                          activeRunnerId,
                          selectedRunnerId,
                          selectedRunnerName,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Workspace Layout
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Sidebar Panel (Animated Width, Margin, Border, and Corner Radius)
                    Padding(
                      padding: EdgeInsets.only(
                        left: isSidebarExpanded ? 12 : 0,
                        right: isSidebarExpanded ? 4 : 0,
                        top: isSidebarExpanded ? 12 : 0,
                        bottom: isSidebarExpanded ? 12 : 0,
                      ),
                      child: AnimatedContainer(
                        key: GuideKeys.playbackHistoryKey,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: isSidebarExpanded ? 304 : 0,
                        height: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: isSidebarExpanded
                              ? Border.all(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: SizedBox(
                            width: 304,
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
                                // Scrollable History Cards
                                const Expanded(child: RunnerHistoryView()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Right Details Content
                    Expanded(
                      child: selectedVideoId != null && selectedVideoId.isEmpty
                          ? _buildEmptyPlaceholder()
                          : CustomScrollView(
                              cacheExtent: 50000,
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.all(12),
                                  sliver: SliverMasonryGrid(
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    gridDelegate:
                                        const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                        ),
                                    delegate: SliverChildListDelegate([
                                      VideoPlayerView(key: GuideKeys.playbackPlayerKey),
                                      GraphListView(key: GuideKeys.playbackChartsKey),
                                      RoundedBoxWidget(
                                        key: GuideKeys.playbackInfoKey,
                                        child: const VideoInfoView(),
                                      ),
                                      RoundedBoxWidget(
                                        key: GuideKeys.playbackActionsKey,
                                        child: const SessionActionsView(),
                                      ),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Mobile Layout (Stacked)
        final runnerHistory = activeRunnerId != null
            ? ref.watch(runnerHistoryProvider(activeRunnerId))
            : null;
        final activeSession = runnerHistory?.whenOrNull(
          data: (sessions) {
            if (sessions.isEmpty) return null;
            return sessions.firstWhere(
              (s) => s.runSessionId == selectedVideoId,
              orElse: () => sessions.first,
            );
          },
        );

        return Stack(
          children: [
            CustomScrollView(
              cacheExtent: 50000,
              slivers: [
                // Runner Selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                    child: Container(
                      key: GuideKeys.playbackRunnerKey,
                      child: AsyncValueWidget(
                        value: runners,
                        loading: const RunnerDropdownShimmer(),
                        data: (List<RunnerInfo> items) => _buildRunnerDropdown(
                          context,
                          items,
                          activeRunnerId,
                          selectedRunnerId,
                          selectedRunnerName,
                        ),
                      ),
                    ),
                  ),
                ),

                // Record Selector Card for Mobile (Always present with placeholder support)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                    child: _buildMobileRecordSelector(context, ref, activeSession),
                  ),
                ),

                if (selectedVideoId != null && selectedVideoId.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyPlaceholder())
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverMasonryGrid(
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                      ),
                      delegate: SliverChildListDelegate([
                        VideoPlayerView(key: GuideKeys.playbackPlayerKey),
                        GraphListView(key: GuideKeys.playbackChartsKey),
                        RoundedBoxWidget(
                          key: GuideKeys.playbackInfoKey,
                          child: const VideoInfoView(),
                        ),
                        RoundedBoxWidget(
                          key: GuideKeys.playbackActionsKey,
                          child: const SessionActionsView(),
                        ),
                      ]),
                    ),
                  ),
              ],
            ),

            // Mobile History Bottom Sheet Modal
            if (isSidebarExpanded)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    ref.read(playbackSidebarExpandedProvider.notifier).state = false;
                  },
                  child: Container(
                    color: Colors.black45,
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        key: GuideKeys.playbackHistoryKey,
                        padding: const EdgeInsets.only(top: 16),
                        height: MediaQuery.of(context).size.height * 0.6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.analysisHistory,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      ref.read(playbackSidebarExpandedProvider.notifier).state =
                                          false;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: RunnerHistoryView(
                                onSessionSelected: () {
                                  ref.read(playbackSidebarExpandedProvider.notifier).state = false;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRunnerDropdown(
    BuildContext context,
    List<RunnerInfo> items,
    String? activeRunnerId,
    String? selectedRunnerId,
    String selectedRunnerName,
  ) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Row(
                children: [
                  const Icon(Icons.people, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      l10n.selectRunner,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              items: items
                  .map(
                    (RunnerInfo item) => DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              value: activeRunnerId,
              onChanged: (value) {
                setState(() {
                  ref.read(playbackSelectedRunnerIdProvider.notifier).state = value;
                });
                ref.read(playbackSelectedRunSessionIdProvider.notifier).state = items
                    .firstWhere((item) => item.id == value)
                    .lastVideoId;
              },
              buttonStyleData: ButtonStyleData(
                height: 50,
                padding: const EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black26),
                ),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.arrow_forward_ios_outlined),
                iconSize: 12,
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                offset: const Offset(0, 0),
                scrollbarTheme: const ScrollbarThemeData(radius: Radius.circular(40)),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.only(left: 12, right: 12),
              ),
            ),
          ),
        ),
        if (selectedRunnerId != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.deleteRunnerConfirmTitle),
                  content: Text(l10n.deleteRunnerConfirmMessage(selectedRunnerName)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                if (!context.mounted) return;

                try {
                  final backend = ref.read(backendProvider);
                  await backend.deleteRunner(selectedRunnerId);

                  ref.read(playbackSelectedRunnerIdProvider.notifier).state = null;
                  ref.read(playbackSelectedRunSessionIdProvider.notifier).state = null;
                  ref.invalidate(runnerProvider);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
                }
              }
            },
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 24),
            tooltip: l10n.deleteRunnerConfirmTitle,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          context.l10n.noHistoryFound,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMobileRecordSelector(
    BuildContext context,
    WidgetRef ref,
    RunSessionInfo? activeSession,
  ) {
    final l10n = context.l10n;
    return Card(
      key: GuideKeys.playbackSidebarToggleKey,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ref.read(playbackSidebarExpandedProvider.notifier).state = true;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.analysisHistory,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeSession != null
                          ? "${DateFormat('yyyy-MM-dd HH:mm').format(activeSession.date)} (${activeSession.cameraCount} ${l10n.cameras})"
                          : l10n.noHistoryFound,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
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
