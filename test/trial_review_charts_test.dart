import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/entities/step_data.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/feature/trial_review/widget/multi_trial_step_length_chart.dart';
import 'package:frontend/feature/trial_review/widget/step_length_frequency_chart.dart';
import 'package:frontend/feature/trial_review/widget/step_lateral_path_chart.dart';
import 'package:frontend/feature/trial_review/widget/trial_video_controller.dart';

void main() {
  testWidgets(
    'step frequency remains visible when step length is unavailable',
    (tester) async {
      final data = StepsData(
        avgCadenceSpm: 205,
        steps: [
          StepSample(stepIndex: 1, timeSec: 0.1, cam: 0, cadenceSpm: 200),
          StepSample(stepIndex: 2, timeSec: 0.4, cam: 0, cadenceSpm: 210),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trialVideoControllerProvider('trial').overrideWith(
              (ref) => Completer<TrialVideoPlaybackController>().future,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                child: StepLengthFrequencyChart(
                  runSessionId: 'trial',
                  data: data,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('步頻 (spm)'), findsWidgets);
      expect(find.text('沒有步幅/步頻資料'), findsNothing);
    },
  );

  testWidgets('multi-trial chart explains when every trial lacks step length', (
    tester,
  ) async {
    final data = StepsData(
      avgCadenceSpm: 205,
      steps: [
        StepSample(stepIndex: 1, timeSec: 0.1, cam: 0, cadenceSpm: 200),
        StepSample(stepIndex: 2, timeSec: 0.4, cam: 0, cadenceSpm: 210),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trialVideoControllerProvider('trial').overrideWith(
            (ref) => Completer<TrialVideoPlaybackController>().future,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              child: MultiTrialStepLengthChart(
                currentRunSessionId: 'trial',
                trials: {'trial': data},
                trialColors: const {'trial': Colors.blue},
                trialLabels: const {'trial': '目前試跳'},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('沒有有效步幅可供比較'), findsOneWidget);
  });

  testWidgets('labels the footprint chart as synchronized with playback', (
    tester,
  ) async {
    final data = StepsData(
      steps: [
        StepSample(
          stepIndex: 1,
          timeSec: 0.1,
          cam: 0,
          foot: 'left',
          worldXM: 1,
          worldYM: 0.5,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 800, child: StepLateralPathChart(data: data)),
        ),
      ),
    );

    expect(find.text('同步腳步俯視路徑（固定比例，公尺）'), findsOneWidget);
    expect(find.text('等待影片同步'), findsOneWidget);
  });

  test('visible footsteps follow active camera and playback time', () {
    final data = StepsData(
      steps: [
        StepSample(stepIndex: 1, timeSec: 0.2, cam: 0),
        StepSample(stepIndex: 2, timeSec: 0.8, cam: 0),
        StepSample(stepIndex: 3, timeSec: 0.3, cam: 1),
        StepSample(stepIndex: 4, timeSec: 0.9, cam: 1),
        StepSample(stepIndex: 5, timeSec: 0.1, cam: 2),
      ],
    );

    final visible = visibleStepsAtPlayback(
      data,
      activeCameraIndex: 1,
      position: const Duration(milliseconds: 500),
    );

    expect(visible.map((step) => step.stepIndex), [1, 2, 3]);
  });
}
