import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/feature/analysis/analysis_event.dart';
import 'package:frontend/feature/analysis/analysis_request.dart';
import 'package:frontend/feature/analysis/local_analysis_adapter.dart';
import 'package:runner_pose/runner_analysis.dart';

class FakeLocalPlatform implements RunnerAnalysisPlatform {
  final events = StreamController<LocalAnalysisEvent>.broadcast();
  LocalAnalysisRequest? request;
  var cancelCalls = 0;
  var disposeCalls = 0;

  @override
  Stream<LocalAnalysisEvent> analyze(LocalAnalysisRequest request) {
    this.request = request;
    return events.stream;
  }

  @override
  Future<void> cancel() async => cancelCalls++;

  @override
  Future<void> dispose() async {
    disposeCalls++;
    if (!events.isClosed) await events.close();
  }
}

AnalysisRequest request() => AnalysisRequest(
  runnerId: 'runner-1',
  date: DateTime(2026, 10, 4),
  cameraCount: 1,
  fps: 60,
  videos: const [
    AnalysisVideoInput(
      cameraIndex: 0,
      fps: 59.94,
      rotationDegrees: 90,
      frameWidth: 1920,
      frameHeight: 1080,
      path: '/tmp/input.mov',
    ),
  ],
);

void main() {
  test('local adapter sends paths and maps completion bundle without video bytes', () async {
    final platform = FakeLocalPlatform();
    final adapter = LocalAnalysisAdapter(
      analysis: RunnerAnalysis(platform: platform),
      requestIdFactory: () => '11111111-1111-4111-8111-111111111111',
    );

    final receivedFuture = adapter.analyze(request()).toList();
    await Future<void>.delayed(Duration.zero);
    platform.events.add(
      const LocalAnalysisEvent(
        stage: LocalAnalysisStage.pose2d,
        status: LocalAnalysisEventStatus.started,
        sequence: 2,
      ),
    );
    platform.events.add(
      const LocalAnalysisEvent(
        stage: LocalAnalysisStage.completed,
        status: LocalAnalysisEventStatus.completed,
        sequence: 6,
        bundlePath: '/results/run-id',
      ),
    );
    await platform.events.close();
    final received = await receivedFuture;

    expect(platform.request!.requestId, '11111111-1111-4111-8111-111111111111');
    expect(platform.request!.videos.single.path, '/tmp/input.mov');
    expect(received.map((event) => event.stage), [AnalysisStage.pose2d, AnalysisStage.completed]);
    expect(received.last.bundlePath, '/results/run-id');

    await adapter.cancel();
    await adapter.dispose();
    expect(platform.cancelCalls, 1);
    expect(platform.disposeCalls, 1);
  });

  test('local adapter preserves typed native failures', () async {
    final platform = FakeLocalPlatform();
    final adapter = LocalAnalysisAdapter(
      analysis: RunnerAnalysis(platform: platform),
      requestIdFactory: () => '11111111-1111-4111-8111-111111111111',
    );

    final terminal = expectLater(
      adapter.analyze(request()),
      emits(
        isA<AnalysisEvent>()
            .having((event) => event.stage, 'stage', AnalysisStage.failed)
            .having((event) => event.errorCode, 'errorCode', 'insufficient_storage')
            .having((event) => event.retriable, 'retriable', isTrue),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    platform.events.add(
      const LocalAnalysisEvent(
        stage: LocalAnalysisStage.failed,
        status: LocalAnalysisEventStatus.failed,
        sequence: 4,
        failure: LocalAnalysisFailure(
          code: 'insufficient_storage',
          message: 'Not enough free space',
          retriable: true,
        ),
      ),
    );
    await platform.events.close();

    await terminal;
    await adapter.dispose();
  });
}
