import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/feature/auth/auth_provider.dart';
import 'package:frontend/feature/auth/auth_state.dart';
import 'package:frontend/feature/guide/guide_steps_factory.dart';
import 'package:frontend/feature/guide/guide_tour_service.dart';
import 'package:frontend/feature/playback/playback_provider.dart';
import 'package:frontend/feature/record/record_controller.dart';
import 'package:frontend/feature/record/widget/record_tour_placeholder_view.dart';
import 'package:frontend/feature/upload/upload_completion.dart';
import 'package:frontend/feature/upload/upload_provider.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/utils/router.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';

class HomePage extends ConsumerStatefulWidget {
  final Widget child;
  const HomePage({super.key, required this.child});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  final SidebarXController _controller = SidebarXController(selectedIndex: 0);
  late TabController _tabController;
  bool _isSidebarOpen = false;
  bool _updatingFromRouter = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _controller.addListener(() {
      if (_updatingFromRouter) return;
      final index = _controller.selectedIndex;

      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }

      if (index == 0) context.goNamed(AppRoute.playback.name);
      if (index == 1) context.goNamed(AppRoute.upload.name);
      if (index == 2) context.goNamed(AppRoute.record.name);
      if (index == 3) context.goNamed(AppRoute.trialReview.name);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final location = GoRouterState.of(context).uri.toString();
    _updatingFromRouter = true;
    if (location.startsWith('/playback')) {
      _controller.selectIndex(0);
      _tabController.index = 0;
    } else if (location.startsWith('/upload')) {
      _controller.selectIndex(1);
      _tabController.index = 1;
    } else if (location.startsWith('/record')) {
      _controller.selectIndex(2);
      _tabController.index = 2;
    } else if (location.startsWith('/trial_review')) {
      _controller.selectIndex(3);
      _tabController.index = 3;
    }
    _isSidebarOpen = false;
    _updatingFromRouter = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    final authState = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10n = context.l10n;
    final showRecordTourFullscreen = ref.watch(recordTourAnchorFullscreenOpenProvider);

    ref.listen(uploadCompletionProvider, (previous, next) {
      if (next == null || next.id == previous?.id) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.uploadSuccess),
              action: SnackBarAction(
                label: l10n.viewUploadedVideo,
                onPressed: () {
                  context.goNamed(
                    AppRoute.playback.name,
                    queryParameters: {'runnerId': next.runnerId, 'videoId': next.runSessionId},
                  );
                },
              ),
            ),
          );
        ref.read(uploadCompletionProvider.notifier).consume(next.id);
      });
    });

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              _controller.selectedIndex == 0
                  ? l10n.navPlayback
                  : _controller.selectedIndex == 1
                  ? l10n.navUpload
                  : _controller.selectedIndex == 2
                  ? l10n.navRecord
                  // TODO: not wired into the l10n ARB files yet. Add
                  // navTrialReview to the .arb files and swap this literal
                  // for l10n.navTrialReview when doing a localization pass.
                  : '賽事回顧',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color.fromARGB(255, 121, 169, 234),
            elevation: 4,
            shadowColor: Colors.black.withAlpha(80),
            leading: isPortrait
                ? null
                : IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      setState(() {
                        _isSidebarOpen = !_isSidebarOpen;
                      });
                    },
                  ),
            actions: [
              if (authState.status == AuthStatus.authenticated && authState.username != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        authState.username!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                offset: const Offset(0, 4),
                icon: const Icon(Icons.language, color: Colors.white),
                tooltip: l10n.switchLanguage,
                color: const Color(0xFF1E2638),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white24),
                ),
                onSelected: (code) {
                  ref.read(localeProvider.notifier).setLocale(Locale(code));
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'zh',
                    child: Row(
                      children: [
                        Text(
                          '🇹🇼 繁體中文',
                          style: TextStyle(
                            color: currentLocale.languageCode == 'zh'
                                ? const Color(0xFF79A9EA)
                                : Colors.white,
                            fontWeight: currentLocale.languageCode == 'zh'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (currentLocale.languageCode == 'zh') ...[
                          const Spacer(),
                          const Icon(Icons.check, size: 16, color: Color(0xFF79A9EA)),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'en',
                    child: Row(
                      children: [
                        Text(
                          '🇺🇸 English',
                          style: TextStyle(
                            color: currentLocale.languageCode == 'en'
                                ? const Color(0xFF79A9EA)
                                : Colors.white,
                            fontWeight: currentLocale.languageCode == 'en'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (currentLocale.languageCode == 'en') ...[
                          const Spacer(),
                          const Icon(Icons.check, size: 16, color: Color(0xFF79A9EA)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              // 賽事回顧 (index 3) has no guided tour yet.
              if (_controller.selectedIndex != 3)
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  tooltip: l10n.tourHelp,
                  onPressed: () => _startCurrentPageTour(force: true),
                ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: l10n.navLogout,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.logoutConfirmTitle),
                      content: Text(l10n.logoutConfirmMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ref.read(authProvider.notifier).logout();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          child: Text(l10n.navLogout, style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Row(
            children: [
              if (!isPortrait)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _isSidebarOpen ? 120 : 0),
                    child: SidebarX(
                      controller: _controller,
                      showToggleButton: false,
                      items: [
                        SidebarXItem(icon: Icons.play_arrow, label: l10n.navPlayback),
                        SidebarXItem(icon: Icons.upload, label: l10n.navUpload),
                        SidebarXItem(icon: Icons.videocam, label: l10n.navRecord),
                        // TODO: not wired into l10n yet, see AppBar title note.
                        const SidebarXItem(icon: Icons.emoji_events, label: '賽事回顧'),
                      ],
                    ),
                  ),
                ),
              Expanded(child: widget.child),
            ],
          ),
          bottomNavigationBar: isPortrait
              ? ConvexAppBar(
                  controller: _tabController,
                  onTap: (index) {
                    _controller.selectIndex(index);
                  },
                  items: const [
                    TabItem(icon: Icons.play_arrow),
                    TabItem(icon: Icons.upload),
                    TabItem(icon: Icons.videocam),
                    TabItem(icon: Icons.emoji_events),
                  ],
                  backgroundColor: const Color.fromARGB(255, 121, 169, 234),
                )
              : null,
        ),
        if (showRecordTourFullscreen) const RecordTourAnchorFullscreenDialog(),
      ],
    );
  }

  void _startCurrentPageTour({bool force = false}) {
    final index = _controller.selectedIndex;
    if (index == 0) {
      ref.read(playbackSidebarExpandedProvider.notifier).state = false;
      final steps = GuideStepsFactory.getPlaybackSteps(context, ref);
      GuideTourService.startTour(
        context: context,
        tourKey: GuideTourService.tourPlayback,
        steps: steps,
        force: force,
      );
    } else if (index == 1) {
      ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
      final steps = GuideStepsFactory.getUploadSteps(context, ref);
      GuideTourService.startTour(
        context: context,
        tourKey: GuideTourService.tourUpload,
        steps: steps,
        onFinish: () {
          ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
        },
        onSkip: () {
          ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
        },
        force: force,
      );
    } else if (index == 2) {
      GuideTourService.startRecordTour(context: context, ref: ref, force: force);
    }
  }
}
