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

class FakeLocalResultSynchronizer implements LocalResultSynchronizer {
  AnalysisRequest? request;
  String? bundlePath;

  @override
  Future<LocalSyncResult> sync(AnalysisRequest request, String bundlePath) async {
    this.request = request;
    this.bundlePath = bundlePath;
    return const LocalSyncResult(runSessionId: 'session-local', analysisRunId: 'run-local');
  }
}

class HangingLocalResultSynchronizer implements LocalResultSynchronizer {
  final completer = Completer<LocalSyncResult>();

  @override
  Future<LocalSyncResult> sync(AnalysisRequest request, String bundlePath) => completer.future;
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

  test('local adapter syncs a completed bundle before exposing runSessionId', () async {
    final platform = FakeLocalPlatform();
    final synchronizer = FakeLocalResultSynchronizer();
    final adapter = LocalAnalysisAdapter(
      analysis: RunnerAnalysis(platform: platform),
      synchronizer: synchronizer,
      requestIdFactory: () => '11111111-1111-4111-8111-111111111111',
    );

    final receivedFuture = adapter.analyze(request()).toList();
    await Future<void>.delayed(Duration.zero);
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

    expect(received.map((event) => event.stage), [AnalysisStage.sync, AnalysisStage.completed]);
    expect(received.last.runSessionId, 'session-local');
    expect(received.last.bundlePath, '/results/run-id');
    expect(synchronizer.bundlePath, '/results/run-id');

    await adapter.dispose();
  });

  test('local adapter cancels and reports the stage after native inactivity', () async {
    final platform = FakeLocalPlatform();
    final adapter = LocalAnalysisAdapter(
      analysis: RunnerAnalysis(platform: platform),
      nativeInactivityTimeout: const Duration(milliseconds: 20),
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
    final received = await receivedFuture;

    expect(received.map((event) => event.stage), [AnalysisStage.pose2d, AnalysisStage.failed]);
    expect(received.last.errorCode, 'local_no_progress_timeout');
    expect(received.last.retriable, isTrue);
    expect(received.last.message, contains('pose2d'));
    expect(platform.cancelCalls, 1);

    await adapter.dispose();
  });

  test('local adapter reports sync timeout and keeps the completed bundle', () async {
    final platform = FakeLocalPlatform();
    final synchronizer = HangingLocalResultSynchronizer();
    final adapter = LocalAnalysisAdapter(
      analysis: RunnerAnalysis(platform: platform),
      synchronizer: synchronizer,
      syncTimeout: const Duration(milliseconds: 20),
      requestIdFactory: () => '11111111-1111-4111-8111-111111111111',
    );

    final receivedFuture = adapter.analyze(request()).toList();
    await Future<void>.delayed(Duration.zero);
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

    expect(received.map((event) => event.stage), [AnalysisStage.sync, AnalysisStage.failed]);
    expect(received.last.errorCode, 'sync_timeout');
    expect(received.last.retriable, isTrue);
    expect(received.last.bundlePath, '/results/run-id');
    expect(received.last.message, contains('同步'));

    await adapter.dispose();
  });
}
