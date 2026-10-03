import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/feature/guide/guide_steps_factory.dart';
import 'package:frontend/feature/guide/guide_tour_model.dart';
import 'package:frontend/feature/guide/guide_tour_overlay.dart';
import 'package:frontend/feature/guide/record_tour_inquiry_dialog.dart';
import 'package:frontend/feature/record/record_controller.dart';
import 'package:frontend/feature/record/record_enums.dart';
import 'package:frontend/utils/api.dart';
import 'package:frontend/utils/net_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuideTourService {
  static const String keyPrefix = 'guide_tour_seen_';

  static const String tourPlayback = 'playback';
  static const String tourRecord = 'record';
  static const String tourUpload = 'upload';
  static const String tourNavigation = 'navigation';

  /// Sync seen tours from backend to local SharedPreferences cache
  static Future<void> syncSeenTours(List<String> seenTours) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(keyPrefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    for (final tourKey in seenTours) {
      await prefs.setBool('$keyPrefix$tourKey', true);
    }
  }

  /// Reset all local tour flags (e.g. on logout)
  static Future<void> resetAllLocalTours() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(keyPrefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  /// Check if the user has already seen the specified tour
  static Future<bool> hasSeenTour(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$keyPrefix$tourKey') ?? false;
  }

  /// Mark the specified tour as seen (both locally and on backend)
  static Future<void> markTourSeen(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$keyPrefix$tourKey', true);

    try {
      await NetUtils().reqeustData<Map<String, dynamic>>(
        '${API.baseUrl}/auth/seen-tours',
        method: DioMethod.post,
        postData: {'tour_key': tourKey},
      );
    } catch (_) {}
  }

  /// Reset tour seen status (for testing or "Replay Tutorial" action)
  static Future<void> resetTourSeen(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$keyPrefix$tourKey');

    try {
      await NetUtils().reqeustData<Map<String, dynamic>>(
        '${API.baseUrl}/auth/reset-tours',
        method: DioMethod.post,
        postData: {'tour_key': tourKey},
      );
    } catch (_) {}
  }

  /// Reset all tours
  static Future<void> resetAllTours() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(keyPrefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }

    try {
      await NetUtils().reqeustData<Map<String, dynamic>>(
        '${API.baseUrl}/auth/reset-tours',
        method: DioMethod.post,
        postData: {},
      );
    } catch (_) {}
  }

  /// Launch a guide tour if not yet seen, or if forced (e.g. user tapped '❓')
  static Future<void> startTour({
    required BuildContext context,
    required String tourKey,
    required List<TourStep> steps,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
    bool force = false,
  }) async {
    if (!force) {
      final seen = await hasSeenTour(tourKey);
      if (seen) return;
    }

    if (!context.mounted) return;

    await GuideTourOverlay.show(
      context: context,
      steps: steps,
      onFinish: () {
        markTourSeen(tourKey);
        onFinish?.call();
      },
      onSkip: () {
        markTourSeen(tourKey);
        onSkip?.call();
      },
    );
  }

  /// Launch Record page tour, showing the Role Inquiry Dialog first if not in a real room
  static Future<void> startRecordTour({
    required BuildContext context,
    required WidgetRef ref,
    bool force = false,
  }) async {
    if (!force) {
      final seen = await hasSeenTour(tourRecord);
      if (seen) return;
    }

    if (!context.mounted) return;

    final inRealRoom =
        ref.read(recordControllerProvider).status != RecordStatus.idle &&
        ref.read(recordControllerProvider).status != RecordStatus.connecting;

    if (inRealRoom) {
      final steps = GuideStepsFactory.getRecordSteps(context, ref);
      await startTour(
        context: context,
        tourKey: tourRecord,
        steps: steps,
        onFinish: () {
          ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
          ref.read(recordTourAnchorStageProvider.notifier).state =
              RecordTourAnchorStage.normalFullscreen;
          ref.read(recordTourDemoInRoomProvider.notifier).state = false;
        },
        onSkip: () {
          ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
          ref.read(recordTourAnchorStageProvider.notifier).state =
              RecordTourAnchorStage.normalFullscreen;
          ref.read(recordTourDemoInRoomProvider.notifier).state = false;
        },
        force: true,
      );
      return;
    }

    // Show Inquiry Dialog first
    final choice = await RecordTourInquiryDialog.show(context);
    if (choice == null || !context.mounted) {
      if (!force) {
        markTourSeen(tourRecord);
      }
      return;
    }

    final steps = GuideStepsFactory.getRecordStepsByChoice(context, ref, choice);

    await startTour(
      context: context,
      tourKey: tourRecord,
      steps: steps,
      onFinish: () {
        ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
        ref.read(recordTourAnchorStageProvider.notifier).state =
            RecordTourAnchorStage.normalFullscreen;
        ref.read(recordTourDemoInRoomProvider.notifier).state = false;
      },
      onSkip: () {
        ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
        ref.read(recordTourAnchorStageProvider.notifier).state =
            RecordTourAnchorStage.normalFullscreen;
        ref.read(recordTourDemoInRoomProvider.notifier).state = false;
      },
      force: true,
    );
  }
}
