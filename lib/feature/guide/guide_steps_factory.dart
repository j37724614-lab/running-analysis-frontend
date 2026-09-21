import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/feature/guide/guide_tour_model.dart';
import 'package:frontend/feature/playback/playback_provider.dart';
import 'package:frontend/feature/record/record_controller.dart';
import 'package:frontend/feature/record/record_enums.dart';
import 'package:frontend/feature/upload/upload_provider.dart';
import 'package:frontend/feature/upload/widget/upload_enums.dart';
import 'package:frontend/feature/upload/widget/upload_form_provider.dart';
import 'package:frontend/utils/locale_provider.dart';

class GuideKeys {
  // Navigation / Home
  static final GlobalKey navSidebarKey = GlobalKey();
  static final GlobalKey navLangKey = GlobalKey();
  static final GlobalKey navHelpKey = GlobalKey();

  // Playback Page
  static final GlobalKey playbackRunnerKey = GlobalKey();
  static final GlobalKey playbackSidebarToggleKey = GlobalKey();
  static final GlobalKey playbackHistoryKey = GlobalKey();
  static final GlobalKey playbackPlayerKey = GlobalKey();
  static final GlobalKey playbackInfoKey = GlobalKey();
  static final GlobalKey playbackChartsKey = GlobalKey();
  static final GlobalKey playbackActionsKey = GlobalKey();

  // Upload Page (All)
  static final GlobalKey uploadTabsKey = GlobalKey();
  static final GlobalKey uploadRunnerKey = GlobalKey();
  static final GlobalKey uploadConfigKey = GlobalKey();
  static final GlobalKey uploadVideoKey = GlobalKey();
  static final GlobalKey uploadAnchorKey = GlobalKey();
  static final GlobalKey uploadSubmitKey = GlobalKey();

  // Upload Page (Separately)
  static final GlobalKey uploadSepTabsKey = GlobalKey();
  static final GlobalKey uploadSepHistoryKey = GlobalKey();
  static final GlobalKey uploadSepCameraKey = GlobalKey();
  static final GlobalKey uploadSepVideoKey = GlobalKey();
  static final GlobalKey uploadSepSubmitKey = GlobalKey();

  // Record Page
  static final GlobalKey recordRoleMasterKey = GlobalKey();
  static final GlobalKey recordRoleSlaveKey = GlobalKey();
  static final GlobalKey recordRoomInfoKey = GlobalKey();
  static final GlobalKey recordConfigKey = GlobalKey();
  static final GlobalKey recordLocalRecordKey = GlobalKey();
  static final GlobalKey recordDevicesKey = GlobalKey();
  static final GlobalKey recordCameraKey = GlobalKey();
  static final GlobalKey recordAnchorToggleKey = GlobalKey();
  static final GlobalKey recordAnchorCanvasKey = GlobalKey();
  static final GlobalKey recordDistanceDialogKey = GlobalKey();
  static final GlobalKey recordFullscreenRecordKey = GlobalKey();
  static final GlobalKey recordExitFullscreenKey = GlobalKey();
  static final GlobalKey recordButtonKey = GlobalKey();
  static final GlobalKey recordRequestControlKey = GlobalKey();
  static final GlobalKey recordSlaveCameraPosKey = GlobalKey();
  static final GlobalKey recordLeaveRoomKey = GlobalKey();
}

class GuideStepsFactory {
  static bool _isMobileDevice(BuildContext context) {
    final isMobilePlatform =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final isShortScreen = MediaQuery.of(context).size.shortestSide < 600;
    return isMobilePlatform || isShortScreen;
  }

  static List<TourStep> getPlaybackSteps(BuildContext context, [WidgetRef? ref]) {
    final l10n = context.l10n;
    final isLargeScreen = MediaQuery.sizeOf(context).width >= 900;

    if (isLargeScreen) {
      return [
        TourStep(
          targetKey: GuideKeys.playbackRunnerKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(playbackSidebarExpandedProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 150));
            }
          },
          title: l10n.tourPlaybackRunnerTitle,
          description: l10n.tourPlaybackRunnerDesc,
          icon: Icons.person_search,
          borderRadius: 12,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackSidebarToggleKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(playbackSidebarExpandedProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 150));
            }
          },
          title: l10n.tourPlaybackSidebarToggleTitle,
          description: l10n.tourPlaybackSidebarToggleDesc,
          icon: Icons.view_sidebar_rounded,
          borderRadius: 12,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackHistoryKey,
          onBeforeStep: () async {
            // Expand sidebar for Step 3 after Step 2 is explained
            if (ref != null) {
              ref.read(playbackSidebarExpandedProvider.notifier).state = true;
              await Future.delayed(const Duration(milliseconds: 300));
            }
          },
          title: l10n.tourPlaybackHistoryTitle,
          description: l10n.tourPlaybackHistoryDesc,
          icon: Icons.history,
          borderRadius: 12,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackPlayerKey,
          title: l10n.tourPlaybackPlayerTitle,
          description: l10n.tourPlaybackPlayerDesc,
          icon: Icons.smart_display,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackInfoKey,
          title: l10n.tourPlaybackInfoTitle,
          description: l10n.tourPlaybackInfoDesc,
          icon: Icons.insights,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackChartsKey,
          title: l10n.tourPlaybackChartsTitle,
          description: l10n.tourPlaybackChartsDesc,
          icon: Icons.show_chart,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackActionsKey,
          title: l10n.tourPlaybackActionsTitle,
          description: l10n.tourPlaybackActionsDesc,
          icon: Icons.assignment_outlined,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
      ];
    } else {
      // Mobile View: 7 Steps matching desktop flow
      return [
        TourStep(
          targetKey: GuideKeys.playbackRunnerKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(playbackSidebarExpandedProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 150));
            }
          },
          title: l10n.tourPlaybackRunnerTitle,
          description: l10n.tourPlaybackRunnerDesc,
          icon: Icons.person_search,
          borderRadius: 12,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackSidebarToggleKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(playbackSidebarExpandedProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 150));
            }
          },
          title: l10n.tourPlaybackMobileRecordTitle,
          description: l10n.tourPlaybackMobileRecordDesc,
          icon: Icons.history_toggle_off_rounded,
          borderRadius: 12,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackHistoryKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(playbackSidebarExpandedProvider.notifier).state = true;
              await Future.delayed(const Duration(milliseconds: 300));
            }
          },
          title: l10n.tourPlaybackHistoryTitle,
          description: l10n.tourPlaybackHistoryDesc,
          icon: Icons.history,
          borderRadius: 20,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackPlayerKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(playbackSidebarExpandedProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 200));
            }
          },
          title: l10n.tourPlaybackPlayerTitle,
          description: l10n.tourPlaybackPlayerDesc,
          icon: Icons.smart_display,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackInfoKey,
          title: l10n.tourPlaybackInfoTitle,
          description: l10n.tourPlaybackInfoDesc,
          icon: Icons.insights,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackChartsKey,
          title: l10n.tourPlaybackChartsTitle,
          description: l10n.tourPlaybackChartsDesc,
          icon: Icons.show_chart,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.playbackActionsKey,
          title: l10n.tourPlaybackActionsTitle,
          description: l10n.tourPlaybackActionsDesc,
          icon: Icons.assignment_outlined,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
      ];
    }
  }

  static List<TourStep> getUploadSteps(BuildContext context, [WidgetRef? ref]) {
    final l10n = context.l10n;
    final uploadType = ref?.read(uploadTypeProvider) ?? UploadType.all;

    if (uploadType == UploadType.all) {
      return [
        TourStep(
          targetKey: GuideKeys.uploadTabsKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 100));
            }
          },
          title: l10n.tourUploadTabsTitle,
          description: l10n.tourUploadTabsDesc,
          icon: Icons.tab,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.uploadRunnerKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 100));
            }
          },
          title: l10n.tourUploadRunnerTitle,
          description: l10n.tourUploadRunnerDesc,
          icon: Icons.person_search_rounded,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.uploadConfigKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 100));
            }
          },
          title: l10n.tourUploadConfigTitle,
          description: l10n.tourUploadConfigDesc,
          icon: Icons.tune,
          borderRadius: 16,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.uploadVideoKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 100));
            }
          },
          title: l10n.tourUploadVideoTitle,
          description: l10n.tourUploadVideoDesc,
          icon: Icons.video_file,
          borderRadius: 16,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.uploadAnchorKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = true;
              await Future.delayed(const Duration(milliseconds: 300));
            }
          },
          title: l10n.tourUploadAnchorTitle,
          description: _isMobileDevice(context)
              ? l10n.tourUploadAnchorDescMobile
              : l10n.tourUploadAnchorDesc,
          icon: Icons.crop_free,
          borderRadius: 20,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.uploadSubmitKey,
          onBeforeStep: () async {
            if (ref != null) {
              ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 200));
            }
          },
          title: l10n.tourUploadSubmitTitle,
          description: l10n.tourUploadSubmitDesc,
          icon: Icons.cloud_upload,
          borderRadius: 25,
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        ),
      ];
    } else {
      // ── 分批上傳工作流程（預設「兩者皆看」9 步驟）──
      return _buildAllSepSteps(context, ref, SepTourChoice.both);
    }
  }

  /// 分批上傳：兩者皆看（完整 9 步驟）
  static List<TourStep> _buildAllSepSteps(
    BuildContext context,
    WidgetRef? ref,
    SepTourChoice currentChoice,
  ) {
    final l10n = context.l10n;
    return [
      TourStep(
        targetKey: GuideKeys.uploadTabsKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadTabsTitle,
        description: l10n.tourUploadTabsDesc,
        icon: Icons.tab,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadRunnerKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadRunnerTitle,
        description: l10n.tourUploadRunnerDesc,
        icon: Icons.person_search_rounded,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepTabsKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.newOne;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadSepTabsTitle,
        description: l10n.tourUploadSepTabsDesc,
        icon: Icons.alt_route,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
        customActionWidget: (context, updateSteps, next) {
          return _SepBranchChoiceSelector(
            context: context,
            ref: ref,
            updateSteps: updateSteps,
            initialChoice: currentChoice,
          );
        },
      ),
      TourStep(
        targetKey: GuideKeys.uploadConfigKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.newOne;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourUploadSepNewTitle,
        description: l10n.tourUploadSepNewDesc,
        icon: Icons.add_circle_outline,
        borderRadius: 20,
        padding: const EdgeInsets.all(8.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepHistoryKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.selectOne;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourUploadSepSelectTitle,
        description: l10n.tourUploadSepSelectDesc,
        icon: Icons.history,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepCameraKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.selectOne;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourUploadSepCameraTitle,
        description: l10n.tourUploadSepCameraDesc,
        icon: Icons.videocam,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepVideoKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadSepVideoTitle,
        description: l10n.tourUploadSepVideoDesc,
        icon: Icons.video_file,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadAnchorKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 300));
          }
        },
        title: l10n.tourUploadAnchorTitle,
        description: _isMobileDevice(context)
            ? l10n.tourUploadAnchorDescMobile
            : l10n.tourUploadAnchorDesc,
        icon: Icons.crop_free,
        borderRadius: 20,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepSubmitKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourUploadSepSubmitTitle,
        description: l10n.tourUploadSepSubmitDesc,
        icon: Icons.cloud_upload,
        borderRadius: 25,
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      ),
    ];
  }

  /// 分批上傳：僅看「新增紀錄」（共 8 步驟）
  static List<TourStep> _buildNewOnlySepSteps(
    BuildContext context,
    WidgetRef? ref,
    SepTourChoice currentChoice,
  ) {
    final l10n = context.l10n;
    return [
      TourStep(
        targetKey: GuideKeys.uploadTabsKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadTabsTitle,
        description: l10n.tourUploadTabsDesc,
        icon: Icons.tab,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadRunnerKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadRunnerTitle,
        description: l10n.tourUploadRunnerDesc,
        icon: Icons.person_search_rounded,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepTabsKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.newOne;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadSepTabsTitle,
        description: l10n.tourUploadSepTabsDesc,
        icon: Icons.alt_route,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
        customActionWidget: (context, updateSteps, next) {
          return _SepBranchChoiceSelector(
            context: context,
            ref: ref,
            updateSteps: updateSteps,
            initialChoice: currentChoice,
          );
        },
      ),
      TourStep(
        targetKey: GuideKeys.uploadConfigKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.newOne;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourUploadSepNewTitle,
        description: l10n.tourUploadSepNewDesc,
        icon: Icons.add_circle_outline,
        borderRadius: 20,
        padding: const EdgeInsets.all(8.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepCameraKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.newOne;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourUploadSepCameraTitle,
        description: l10n.tourUploadSepCameraDesc,
        icon: Icons.videocam,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepVideoKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadSepVideoTitle,
        description: l10n.tourUploadSepVideoDesc,
        icon: Icons.video_file,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadAnchorKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 300));
          }
        },
        title: l10n.tourUploadAnchorTitle,
        description: _isMobileDevice(context)
            ? l10n.tourUploadAnchorDescMobile
            : l10n.tourUploadAnchorDesc,
        icon: Icons.crop_free,
        borderRadius: 20,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepSubmitKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourUploadSepSubmitTitle,
        description: l10n.tourUploadSepSubmitDesc,
        icon: Icons.cloud_upload,
        borderRadius: 25,
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      ),
    ];
  }

  /// 分批上傳：僅看「選擇紀錄」（共 8 步驟）
  static List<TourStep> _buildSelectOnlySepSteps(
    BuildContext context,
    WidgetRef? ref,
    SepTourChoice currentChoice,
  ) {
    final l10n = context.l10n;
    return [
      TourStep(
        targetKey: GuideKeys.uploadTabsKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadTabsTitle,
        description: l10n.tourUploadTabsDesc,
        icon: Icons.tab,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadRunnerKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadRunnerTitle,
        description: l10n.tourUploadRunnerDesc,
        icon: Icons.person_search_rounded,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepTabsKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.selectOne;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadSepTabsTitle,
        description: l10n.tourUploadSepTabsDesc,
        icon: Icons.alt_route,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
        customActionWidget: (context, updateSteps, next) {
          return _SepBranchChoiceSelector(
            context: context,
            ref: ref,
            updateSteps: updateSteps,
            initialChoice: currentChoice,
          );
        },
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepHistoryKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.selectOne;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourUploadSepSelectTitle,
        description: l10n.tourUploadSepSelectDesc,
        icon: Icons.history,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepCameraKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.selectOne;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourUploadSepCameraTitle,
        description: l10n.tourUploadSepCameraDesc,
        icon: Icons.videocam,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepVideoKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
        title: l10n.tourUploadSepVideoTitle,
        description: l10n.tourUploadSepVideoDesc,
        icon: Icons.video_file,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadAnchorKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 300));
          }
        },
        title: l10n.tourUploadAnchorTitle,
        description: _isMobileDevice(context)
            ? l10n.tourUploadAnchorDescMobile
            : l10n.tourUploadAnchorDesc,
        icon: Icons.crop_free,
        borderRadius: 20,
        padding: const EdgeInsets.all(4.0),
      ),
      TourStep(
        targetKey: GuideKeys.uploadSepSubmitKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourUploadSepSubmitTitle,
        description: l10n.tourUploadSepSubmitDesc,
        icon: Icons.cloud_upload,
        borderRadius: 25,
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      ),
    ];
  }

  static List<TourStep> getRecordSteps(BuildContext context, [WidgetRef? ref]) {
    final l10n = context.l10n;
    final inRealRoom =
        ref != null &&
        ref.read(recordControllerProvider).status != RecordStatus.idle &&
        ref.read(recordControllerProvider).status != RecordStatus.connecting;

    if (inRealRoom) {
      final isMaster = ref.read(recordControllerProvider).role == RecordRole.master;
      return [
        TourStep(
          targetKey: GuideKeys.recordRoomInfoKey,
          title: l10n.tourRecordRoomInfoTitle,
          description: l10n.tourRecordRoomInfoDesc,
          icon: Icons.meeting_room_rounded,
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 20.0),
        ),
        if (isMaster) ...[
          TourStep(
            targetKey: GuideKeys.recordConfigKey,
            title: l10n.tourRecordConfigTitle,
            description: l10n.tourRecordConfigDesc,
            icon: Icons.tune,
            borderRadius: 14,
            padding: const EdgeInsets.all(4.0),
          ),
          TourStep(
            targetKey: GuideKeys.recordLocalRecordKey,
            title: l10n.tourRecordLocalTitle,
            description: l10n.tourRecordLocalDesc,
            icon: Icons.video_camera_front,
            borderRadius: 14,
            padding: const EdgeInsets.all(4.0),
          ),
        ] else ...[
          TourStep(
            targetKey: GuideKeys.recordSlaveCameraPosKey,
            title: l10n.tourRecordSlaveCameraPosTitle,
            description: l10n.tourRecordSlaveCameraPosDesc,
            icon: Icons.video_settings,
            borderRadius: 14,
            padding: const EdgeInsets.all(4.0),
          ),
        ],
        TourStep(
          targetKey: GuideKeys.recordDevicesKey,
          title: l10n.tourRecordDevicesTitle,
          description: l10n.tourRecordDevicesDesc,
          icon: Icons.devices,
          borderRadius: 25,
          padding: const EdgeInsets.all(4.0),
        ),
        TourStep(
          targetKey: GuideKeys.recordCameraKey,
          title: l10n.tourRecordCameraTitle,
          description: l10n.tourRecordCameraDesc,
          icon: Icons.camera_alt,
          borderRadius: 18,
          padding: const EdgeInsets.all(4.0),
        ),
        if (isMaster)
          TourStep(
            targetKey: GuideKeys.recordButtonKey,
            title: l10n.tourRecordMasterButtonTitle,
            description: l10n.tourRecordMasterButtonDesc,
            icon: Icons.fiber_manual_record,
            borderRadius: 30,
            padding: const EdgeInsets.all(4.0),
          )
        else
          TourStep(
            targetKey: GuideKeys.recordRequestControlKey,
            title: l10n.tourRecordRequestControlTitle,
            description: l10n.tourRecordRequestControlDesc,
            icon: Icons.pan_tool_alt_rounded,
            borderRadius: 20,
            padding: const EdgeInsets.all(4.0),
          ),
        TourStep(
          targetKey: GuideKeys.recordLeaveRoomKey,
          title: l10n.tourRecordLeaveRoomTitle,
          description: l10n.tourRecordLeaveRoomDesc,
          icon: Icons.exit_to_app,
          borderRadius: 20,
          padding: const EdgeInsets.all(4.0),
        ),
      ];
    }

    return _buildBothRecordSteps(context, ref);
  }

  /// 依據詢問頁面所選的角色流程取得錄影導覽步驟
  static List<TourStep> getRecordStepsByChoice(
    BuildContext context,
    WidgetRef? ref,
    RecordTourChoice choice,
  ) {
    switch (choice) {
      case RecordTourChoice.masterOnly:
        return _buildMasterOnlyRecordSteps(context, ref);
      case RecordTourChoice.slaveOnly:
        return _buildSlaveOnlyRecordSteps(context, ref);
      case RecordTourChoice.both:
        return _buildBothRecordSteps(context, ref);
    }
  }

  /// 錄影流程：兩者皆看（完整 12 步驟）
  static List<TourStep> _buildBothRecordSteps(BuildContext context, WidgetRef? ref) {
    final l10n = context.l10n;
    return [
      // 步驟 1：主控端建立房間
      TourStep(
        targetKey: GuideKeys.recordRoleMasterKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoInRoomProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourRecordMasterTitle,
        description: l10n.tourRecordMasterDesc,
        icon: Icons.stars,
        borderRadius: 14,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 2：從機端加入房間
      TourStep(
        targetKey: GuideKeys.recordRoleSlaveKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoInRoomProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourRecordSlaveTitle,
        description: l10n.tourRecordSlaveDesc,
        icon: Icons.phonelink,
        borderRadius: 14,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 3：房間號碼與目前身分
      TourStep(
        targetKey: GuideKeys.recordRoomInfoKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordRoomInfoTitle,
        description: l10n.tourRecordRoomInfoDesc,
        icon: Icons.meeting_room_rounded,
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 20.0),
      ),

      // 步驟 4：主控端參數配置與跑者設定
      TourStep(
        targetKey: GuideKeys.recordConfigKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordConfigTitle,
        description: l10n.tourRecordConfigDesc,
        icon: Icons.tune,
        borderRadius: 14,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 5：主控端本機鏡頭錄影
      TourStep(
        targetKey: GuideKeys.recordLocalRecordKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordLocalTitle,
        description: l10n.tourRecordLocalDesc,
        icon: Icons.video_camera_front,
        borderRadius: 14,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 6：從機端更改相機機位
      TourStep(
        targetKey: GuideKeys.recordSlaveCameraPosKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.slave;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourRecordSlaveCameraPosTitle,
        description: l10n.tourRecordSlaveCameraPosDesc,
        icon: Icons.video_settings,
        borderRadius: 14,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 7：連線設備清單與機位就緒
      TourStep(
        targetKey: GuideKeys.recordDevicesKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordDevicesTitle,
        description: l10n.tourRecordDevicesDesc,
        icon: Icons.devices,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 7：相機即時預覽與進入全螢幕
      TourStep(
        targetKey: GuideKeys.recordCameraKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordCameraTitle,
        description: l10n.tourRecordCameraDesc,
        icon: Icons.camera_alt,
        borderRadius: 18,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 8：全螢幕相機與啟動錨點設定
      TourStep(
        targetKey: GuideKeys.recordAnchorToggleKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.normalFullscreen;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordAnchorToggleTitle,
        description: l10n.tourRecordAnchorToggleDesc,
        icon: Icons.my_location,
        borderRadius: 22,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 9：跑道六點空間校正
      TourStep(
        targetKey: GuideKeys.recordAnchorCanvasKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.anchorMode;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordAnchorPointsTitle,
        description: _isMobileDevice(context)
            ? l10n.tourRecordAnchorPointsDescMobile
            : l10n.tourRecordAnchorPointsDesc,
        icon: Icons.crop_free,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 10：設定跑道實際物理長度
      TourStep(
        targetKey: GuideKeys.recordDistanceDialogKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.distanceDialog;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordDistanceDialogTitle,
        description: l10n.tourRecordDistanceDialogDesc,
        icon: Icons.straighten,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 11：全螢幕同步錄影
      TourStep(
        targetKey: GuideKeys.recordFullscreenRecordKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.calibratedFullscreen;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordFullscreenRecordTitle,
        description: l10n.tourRecordFullscreenRecordDesc,
        icon: Icons.fiber_manual_record,
        borderRadius: 20,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 12：校正完成與返回房間
      TourStep(
        targetKey: GuideKeys.recordExitFullscreenKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.calibratedFullscreen;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordAnchorDoneTitle,
        description: l10n.tourRecordAnchorDoneDesc,
        icon: Icons.fullscreen_exit,
        shape: TourTargetShape.circle,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 13：主控端一鍵同步錄影與並行上傳
      TourStep(
        targetKey: GuideKeys.recordButtonKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourRecordMasterButtonTitle,
        description: l10n.tourRecordMasterButtonDesc,
        icon: Icons.fiber_manual_record,
        borderRadius: 30,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 15：從機端請求控制權
      TourStep(
        targetKey: GuideKeys.recordRequestControlKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.slave;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourRecordRequestControlTitle,
        description: l10n.tourRecordRequestControlDesc,
        icon: Icons.pan_tool_alt_rounded,
        borderRadius: 20,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 16：離開房間
      TourStep(
        targetKey: GuideKeys.recordLeaveRoomKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordLeaveRoomTitle,
        description: l10n.tourRecordLeaveRoomDesc,
        icon: Icons.exit_to_app,
        borderRadius: 20,
        padding: const EdgeInsets.all(4.0),
      ),
    ];
  }

  /// 錄影流程：僅看「主控端」（共 11 步驟）
  static List<TourStep> _buildMasterOnlyRecordSteps(BuildContext context, WidgetRef? ref) {
    final l10n = context.l10n;
    return [
      // 步驟 1：主控端建立房間
      TourStep(
        targetKey: GuideKeys.recordRoleMasterKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoInRoomProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourRecordMasterTitle,
        description: l10n.tourRecordMasterDesc,
        icon: Icons.stars,
        borderRadius: 14,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 2：房間號碼與目前身分
      TourStep(
        targetKey: GuideKeys.recordRoomInfoKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordRoomInfoTitle,
        description: l10n.tourRecordMasterRoomInfoDesc,
        icon: Icons.meeting_room_rounded,
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 20.0),
      ),

      // 步驟 3：進入房間（參數配置與跑者設定）
      TourStep(
        targetKey: GuideKeys.recordConfigKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordConfigTitle,
        description: l10n.tourRecordConfigDesc,
        icon: Icons.tune,
        borderRadius: 14,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 4：主控端本機鏡頭錄影
      TourStep(
        targetKey: GuideKeys.recordLocalRecordKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordLocalTitle,
        description: l10n.tourRecordLocalDesc,
        icon: Icons.video_camera_front,
        borderRadius: 14,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 5：連線設備清單與機位就緒
      TourStep(
        targetKey: GuideKeys.recordDevicesKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordDevicesTitle,
        description: l10n.tourRecordDevicesDesc,
        icon: Icons.devices,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 6：相機即時預覽與進入全螢幕
      TourStep(
        targetKey: GuideKeys.recordCameraKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordCameraTitle,
        description: l10n.tourRecordCameraDesc,
        icon: Icons.camera_alt,
        borderRadius: 18,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 7：全螢幕相機與啟動錨點設定
      TourStep(
        targetKey: GuideKeys.recordAnchorToggleKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.normalFullscreen;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordAnchorToggleTitle,
        description: l10n.tourRecordAnchorToggleDesc,
        icon: Icons.my_location,
        borderRadius: 22,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 8：跑道六點空間校正
      TourStep(
        targetKey: GuideKeys.recordAnchorCanvasKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.anchorMode;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordAnchorPointsTitle,
        description: _isMobileDevice(context)
            ? l10n.tourRecordAnchorPointsDescMobile
            : l10n.tourRecordAnchorPointsDesc,
        icon: Icons.crop_free,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 9：設定跑道實際物理長度
      TourStep(
        targetKey: GuideKeys.recordDistanceDialogKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.distanceDialog;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordDistanceDialogTitle,
        description: l10n.tourRecordDistanceDialogDesc,
        icon: Icons.straighten,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 10：全螢幕同步錄影
      TourStep(
        targetKey: GuideKeys.recordFullscreenRecordKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.calibratedFullscreen;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordFullscreenRecordTitle,
        description: l10n.tourRecordFullscreenRecordDesc,
        icon: Icons.fiber_manual_record,
        borderRadius: 20,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 11：校正完成與返回房間
      TourStep(
        targetKey: GuideKeys.recordExitFullscreenKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.calibratedFullscreen;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordAnchorDoneTitle,
        description: l10n.tourRecordAnchorDoneDesc,
        icon: Icons.fullscreen_exit,
        shape: TourTargetShape.circle,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 12：主控端一鍵同步錄影
      TourStep(
        targetKey: GuideKeys.recordButtonKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourRecordMasterButtonTitle,
        description: l10n.tourRecordMasterButtonDesc,
        icon: Icons.fiber_manual_record,
        borderRadius: 30,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 13：離開房間
      TourStep(
        targetKey: GuideKeys.recordLeaveRoomKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.master;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordLeaveRoomTitle,
        description: l10n.tourRecordLeaveRoomDesc,
        icon: Icons.exit_to_app,
        borderRadius: 20,
        padding: const EdgeInsets.all(4.0),
      ),
    ];
  }

  /// 錄影流程：僅看「從機端 (Slave)」（共 9 步驟）
  static List<TourStep> _buildSlaveOnlyRecordSteps(BuildContext context, WidgetRef? ref) {
    final l10n = context.l10n;
    return [
      // 步驟 1：從機端加入房間與機位
      TourStep(
        targetKey: GuideKeys.recordRoleSlaveKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoInRoomProvider.notifier).state = false;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourRecordSlaveTitle,
        description: l10n.tourRecordSlaveDesc,
        icon: Icons.phonelink,
        borderRadius: 14,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 2：房間號碼與目前身分
      TourStep(
        targetKey: GuideKeys.recordRoomInfoKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.slave;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordRoomInfoTitle,
        description: l10n.tourRecordSlaveRoomInfoDesc,
        icon: Icons.meeting_room_rounded,
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 20.0),
      ),

      // 步驟 3：從機端更改相機機位
      TourStep(
        targetKey: GuideKeys.recordSlaveCameraPosKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.slave;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourRecordSlaveCameraPosTitle,
        description: l10n.tourRecordSlaveCameraPosDesc,
        icon: Icons.video_settings,
        borderRadius: 14,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 4：連線設備清單與機位就緒
      TourStep(
        targetKey: GuideKeys.recordDevicesKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.slave;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordDevicesTitle,
        description: l10n.tourRecordDevicesDesc,
        icon: Icons.devices,
        borderRadius: 25,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 4：相機即時預覽與進入全螢幕
      TourStep(
        targetKey: GuideKeys.recordCameraKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.slave;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordCameraTitle,
        description: l10n.tourRecordCameraDesc,
        icon: Icons.camera_alt,
        borderRadius: 18,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 5：全螢幕相機與啟動錨點設定
      TourStep(
        targetKey: GuideKeys.recordAnchorToggleKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.normalFullscreen;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordAnchorToggleTitle,
        description: l10n.tourRecordAnchorToggleDesc,
        icon: Icons.my_location,
        borderRadius: 22,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 6：跑道六點空間校正
      TourStep(
        targetKey: GuideKeys.recordAnchorCanvasKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.anchorMode;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordAnchorPointsTitle,
        description: _isMobileDevice(context)
            ? l10n.tourRecordAnchorPointsDescMobile
            : l10n.tourRecordAnchorPointsDesc,
        icon: Icons.crop_free,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 7：設定跑道實際物理長度
      TourStep(
        targetKey: GuideKeys.recordDistanceDialogKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.distanceDialog;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordDistanceDialogTitle,
        description: l10n.tourRecordDistanceDialogDesc,
        icon: Icons.straighten,
        borderRadius: 16,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 8：校正完成與返回房間
      TourStep(
        targetKey: GuideKeys.recordExitFullscreenKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = true;
            ref.read(recordTourAnchorStageProvider.notifier).state =
                RecordTourAnchorStage.calibratedFullscreen;
            await Future.delayed(const Duration(milliseconds: 250));
          }
        },
        title: l10n.tourRecordAnchorDoneTitle,
        description: l10n.tourRecordAnchorDoneDesc,
        icon: Icons.fullscreen_exit,
        shape: TourTargetShape.circle,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 10：從機端請求主控權
      TourStep(
        targetKey: GuideKeys.recordRequestControlKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.slave;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 200));
          }
        },
        title: l10n.tourRecordRequestControlTitle,
        description: l10n.tourRecordRequestControlDesc,
        icon: Icons.pan_tool_alt_rounded,
        borderRadius: 20,
        padding: const EdgeInsets.all(4.0),
      ),

      // 步驟 11：離開房間
      TourStep(
        targetKey: GuideKeys.recordLeaveRoomKey,
        onBeforeStep: () async {
          if (ref != null) {
            ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
            ref.read(recordTourDemoRoleProvider.notifier).state = RecordRole.slave;
            ref.read(recordTourDemoInRoomProvider.notifier).state = true;
            await Future.delayed(const Duration(milliseconds: 150));
          }
        },
        title: l10n.tourRecordLeaveRoomTitle,
        description: l10n.tourRecordLeaveRoomDesc,
        icon: Icons.exit_to_app,
        borderRadius: 20,
        padding: const EdgeInsets.all(4.0),
      ),
    ];
  }
}

enum SepTourChoice { both, newOnly, selectOnly }

enum RecordTourChoice { both, masterOnly, slaveOnly }

class _SepBranchChoiceSelector extends StatefulWidget {
  final BuildContext context;
  final WidgetRef? ref;
  final TourUpdateStepsCallback updateSteps;
  final SepTourChoice initialChoice;

  const _SepBranchChoiceSelector({
    required this.context,
    required this.ref,
    required this.updateSteps,
    required this.initialChoice,
  });

  @override
  State<_SepBranchChoiceSelector> createState() => _SepBranchChoiceSelectorState();
}

class _SepBranchChoiceSelectorState extends State<_SepBranchChoiceSelector> {
  late SepTourChoice _choice;

  @override
  void initState() {
    super.initState();
    _choice = widget.initialChoice;
  }

  void _select(SepTourChoice choice) {
    if (_choice == choice) return;
    setState(() {
      _choice = choice;
    });
    if (choice == SepTourChoice.both) {
      widget.updateSteps(GuideStepsFactory._buildAllSepSteps(widget.context, widget.ref, choice));
    } else if (choice == SepTourChoice.newOnly) {
      widget.updateSteps(
        GuideStepsFactory._buildNewOnlySepSteps(widget.context, widget.ref, choice),
      );
    } else {
      widget.updateSteps(
        GuideStepsFactory._buildSelectOnlySepSteps(widget.context, widget.ref, choice),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.context.l10n;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tourUploadSepChoicePrompt,
            style: const TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            spacing: 6,
            children: [
              _buildRadioOption(
                title: l10n.tourUploadSepChoiceBoth,
                icon: Icons.all_inclusive_rounded,
                color: const Color(0xFF00E5FF),
                isSelected: _choice == SepTourChoice.both,
                onTap: () => _select(SepTourChoice.both),
              ),
              _buildRadioOption(
                title: l10n.tourUploadSepChoiceNew,
                icon: Icons.add_circle_outline_rounded,
                color: const Color(0xFF00E676),
                isSelected: _choice == SepTourChoice.newOnly,
                onTap: () => _select(SepTourChoice.newOnly),
              ),
              _buildRadioOption(
                title: l10n.tourUploadSepChoiceSelect,
                icon: Icons.history_rounded,
                color: const Color(0xFFFFB300),
                isSelected: _choice == SepTourChoice.selectOnly,
                onTap: () => _select(SepTourChoice.selectOnly),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.white24,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 16,
                color: isSelected ? color : Colors.white54,
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: isSelected ? color : Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
