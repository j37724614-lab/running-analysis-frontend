import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/feature/analysis/analysis_event.dart';
import 'package:frontend/feature/analysis/analysis_executor.dart';
import 'package:frontend/feature/analysis/analysis_mode.dart';
import 'package:frontend/feature/analysis/analysis_request.dart';
import 'package:frontend/feature/analysis/analysis_run_controller.dart';
import 'package:frontend/entities/upload_video_file.dart';

/// A controllable test double, not [ServerAnalysisAdapter]/[LocalAnalysisAdapter] -
/// 規劃書 Step 11 explicitly wants the controller's state machine validated
/// against fakes before any UI or native wiring exists.
class FakeAnalysisExecutor implements AnalysisExecutor {
  final controller = StreamController<AnalysisEvent>.broadcast();
  int cancelCallCount = 0;
  int analyzeCallCount = 0;
  AnalysisRequest? lastRequest;

  @override
  Stream<AnalysisEvent> analyze(AnalysisRequest request) {
    analyzeCallCount++;
    lastRequest = request;
    return controller.stream;
  }

  @override
  Future<void> cancel() async {
    cancelCallCount++;
  }

  void emitRunning() => controller.add(const AnalysisEvent(stage: AnalysisStage.tracking));
  void emitCompleted(String runSessionId) =>
      controller.add(AnalysisEvent.completed(runSessionId: runSessionId));
  void emitFailed(Object error) => controller.add(AnalysisEvent.failed(error: error));
}

AnalysisRequest _request() => AnalysisRequest(
  runnerId: 'runner-1',
  date: DateTime(2026, 1, 1),
  cameraCount: 1,
  fps: 60,
  videos: [
    AnalysisVideoInput(
      cameraIndex: 0,
      fps: 60,
      rotationDegrees: 0,
      frameWidth: 1920,
      frameHeight: 1080,
      file: UploadVideoFile(bytes: Uint8List(0), filename: 'a.mov', mimeType: 'video/quicktime'),
    ),
  ],
);

void main() {
  late FakeAnalysisExecutor server;
  late FakeAnalysisExecutor local;
  late AnalysisRunController controller;

  setUp(() {
    server = FakeAnalysisExecutor();
    local = FakeAnalysisExecutor();
    controller = AnalysisRunController(serverExecutor: server, localExecutor: local);
  });

  tearDown(() {
    controller.dispose();
  });

  test('server mode only drives the server executor', () async {
    await controller.start(AnalysisMode.server, _request());
    expect(server.analyzeCallCount, 1);
    expect(local.analyzeCallCount, 0);
    expect(controller.state.isRunning, isTrue);

    server.emitCompleted('session-1');
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.isFullySucceeded, isTrue);
    expect(controller.state.server.runSessionId, 'session-1');
    expect(controller.state.isRunning, isFalse);
  });

  test('local mode only drives the local executor', () async {
    await controller.start(AnalysisMode.local, _request());
    expect(server.analyzeCallCount, 0);
    expect(local.analyzeCallCount, 1);

    local.emitCompleted('session-2');
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.isFullySucceeded, isTrue);
  });

  test('compare starts Local after Server creates the shared RunSession', () async {
    await controller.start(AnalysisMode.compare, _request());
    expect(server.analyzeCallCount, 1);
    expect(local.analyzeCallCount, 0);
    expect(controller.state.comparisonGroupId, isNotNull);
    expect(
      controller.state.comparisonGroupId,
      matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
    );
    expect(server.lastRequest!.comparisonGroupId, controller.state.comparisonGroupId);
    server.emitCompleted('shared-session');
    await Future<void>.delayed(Duration.zero);
    expect(local.analyzeCallCount, 1);
    expect(local.lastRequest!.comparisonGroupId, controller.state.comparisonGroupId);
    expect(server.lastRequest!.requestId, local.lastRequest!.requestId);
  });

  test(
    'compare: one side failing while the other succeeds is partial success, not overwritten',
    () async {
      await controller.start(AnalysisMode.compare, _request());

      server.emitCompleted('server-session');
      await Future<void>.delayed(Duration.zero);
      local.emitFailed(Exception('native bridge unavailable'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isPartialSuccess, isTrue);
      expect(controller.state.isFullySucceeded, isFalse);
      expect(controller.state.isFullyFailed, isFalse);
      // The successful side's result must still be readable - "failure" on the
      // other side never discards it.
      expect(controller.state.server.runSessionId, 'server-session');
      expect(controller.state.server.outcome, RunOutcome.succeeded);
      expect(controller.state.local.outcome, RunOutcome.failed);
    },
  );

  test('compare: both sides succeeding is not reported as partial success', () async {
    await controller.start(AnalysisMode.compare, _request());
    server.emitCompleted('server-session');
    await Future<void>.delayed(Duration.zero);
    local.emitCompleted('local-session');
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.isFullySucceeded, isTrue);
    expect(controller.state.isPartialSuccess, isFalse);
  });

  test(
    'cancel stops running sides and calls executor.cancel(), without touching a finished side',
    () async {
      await controller.start(AnalysisMode.compare, _request());
      server.emitCompleted('server-session'); // server finishes before cancel
      await Future<void>.delayed(Duration.zero);

      await controller.cancel();

      expect(server.cancelCallCount, 1);
      expect(local.cancelCallCount, 1);
      // Server already succeeded - cancel must not downgrade it.
      expect(controller.state.server.outcome, RunOutcome.succeeded);
      expect(controller.state.local.outcome, RunOutcome.cancelled);
    },
  );

  test('retryFailedSide only re-runs the failed side, leaving the succeeded side alone', () async {
    await controller.start(AnalysisMode.compare, _request());
    server.emitCompleted('server-session');
    await Future<void>.delayed(Duration.zero);
    local.emitFailed(Exception('boom'));
    await Future<void>.delayed(Duration.zero);

    await controller.retryFailedSide();

    expect(local.analyzeCallCount, 2); // re-ran
    expect(server.analyzeCallCount, 1); // untouched
    expect(controller.state.server.runSessionId, 'server-session');
    expect(controller.state.local.outcome, RunOutcome.running);
  });

  test('provider wires a real ServerAnalysisAdapter and LocalAnalysisAdapter without throwing', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(analysisRunControllerProvider);
    expect(state.mode, AnalysisMode.server);
    expect(state.isRunning, isFalse);
  });
}
