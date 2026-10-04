import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/feature/analysis/analysis_event.dart';
import 'package:frontend/feature/analysis/analysis_executor.dart';
import 'package:frontend/feature/analysis/analysis_mode.dart';
import 'package:frontend/feature/analysis/analysis_request.dart';
import 'package:frontend/feature/analysis/local_analysis_adapter.dart';
import 'package:frontend/feature/analysis/server_analysis_adapter.dart';

enum RunOutcome { idle, running, succeeded, failed, cancelled }

/// Progress of one side (Server or Local) of a run. Two of these - never one
/// shared status - are what let Compare mode show independent progress and
/// let one side fail without touching the other (規劃書 §6 Compare 路徑 step 4:
/// "任一路徑完成時先保存結果；另一條失敗不能覆蓋或刪除已成功結果").
class SideProgress {
  const SideProgress({this.outcome = RunOutcome.idle, this.lastEvent});

  final RunOutcome outcome;
  final AnalysisEvent? lastEvent;

  bool get isTerminal =>
      outcome == RunOutcome.succeeded ||
      outcome == RunOutcome.failed ||
      outcome == RunOutcome.cancelled;

  String? get runSessionId => lastEvent?.runSessionId;
}

class AnalysisRunState {
  const AnalysisRunState({
    required this.mode,
    this.server = const SideProgress(),
    this.local = const SideProgress(),
    this.comparisonGroupId,
    this.lastRequest,
  });

  final AnalysisMode mode;
  final SideProgress server;
  final SideProgress local;

  /// Non-null only in [AnalysisMode.compare]; pairs the two runs the way
  /// backend Step 10's `AnalysisRun.comparison_group_id` does.
  final String? comparisonGroupId;

  /// Kept so [AnalysisRunController.retryFailedSide] can resubmit without the
  /// caller having to remember and re-pass the original request.
  final AnalysisRequest? lastRequest;

  bool get _usesServer => mode == AnalysisMode.server || mode == AnalysisMode.compare;
  bool get _usesLocal => mode == AnalysisMode.local || mode == AnalysisMode.compare;

  bool get isRunning =>
      (_usesServer && server.outcome == RunOutcome.running) ||
      (_usesLocal && local.outcome == RunOutcome.running);

  bool get isFullySucceeded =>
      (!_usesServer || server.outcome == RunOutcome.succeeded) &&
      (!_usesLocal || local.outcome == RunOutcome.succeeded) &&
      (_usesServer || _usesLocal);

  bool get isFullyFailed =>
      (!_usesServer || server.outcome == RunOutcome.failed) &&
      (!_usesLocal || local.outcome == RunOutcome.failed) &&
      (_usesServer || _usesLocal);

  /// Only meaningful for Compare: exactly one side reached a terminal state
  /// and it was not the same terminal state as the other side once both are
  /// done - i.e. one succeeded while the other failed/was cancelled.
  bool get isPartialSuccess {
    if (mode != AnalysisMode.compare) return false;
    final bothTerminal = server.isTerminal && local.isTerminal;
    if (!bothTerminal) return false;
    final serverOk = server.outcome == RunOutcome.succeeded;
    final localOk = local.outcome == RunOutcome.succeeded;
    return serverOk != localOk;
  }

  AnalysisRunState copyWith({
    AnalysisMode? mode,
    SideProgress? server,
    SideProgress? local,
    String? comparisonGroupId,
    AnalysisRequest? lastRequest,
  }) => AnalysisRunState(
    mode: mode ?? this.mode,
    server: server ?? this.server,
    local: local ?? this.local,
    comparisonGroupId: comparisonGroupId ?? this.comparisonGroupId,
    lastRequest: lastRequest ?? this.lastRequest,
  );
}

SideProgress _sideProgressFor(AnalysisEvent event) {
  final outcome = switch (event.stage) {
    AnalysisStage.completed => RunOutcome.succeeded,
    AnalysisStage.failed => RunOutcome.failed,
    _ => RunOutcome.running,
  };
  return SideProgress(outcome: outcome, lastEvent: event);
}

/// The coordinator described in 規劃書 §4: picks one adapter for
/// [AnalysisMode.server]/[AnalysisMode.local], or fans out to both for
/// [AnalysisMode.compare] - callers (the upload UI) only ever talk to this
/// controller, never to [AnalysisExecutor] directly.
class AnalysisRunController extends StateNotifier<AnalysisRunState> {
  AnalysisRunController({required this.serverExecutor, required this.localExecutor})
    : super(const AnalysisRunState(mode: AnalysisMode.server));

  final AnalysisExecutor serverExecutor;
  final AnalysisExecutor localExecutor;

  StreamSubscription<AnalysisEvent>? _serverSubscription;
  StreamSubscription<AnalysisEvent>? _localSubscription;

  Future<void> start(AnalysisMode mode, AnalysisRequest request) async {
    await _serverSubscription?.cancel();
    await _localSubscription?.cancel();

    state = AnalysisRunState(
      mode: mode,
      comparisonGroupId: mode == AnalysisMode.compare ? _generateComparisonGroupId() : null,
      lastRequest: request,
    );

    if (mode == AnalysisMode.server || mode == AnalysisMode.compare) {
      _startServer(request);
    }
    if (mode == AnalysisMode.local || mode == AnalysisMode.compare) {
      _startLocal(request);
    }
  }

  void _startServer(AnalysisRequest request) {
    state = state.copyWith(server: const SideProgress(outcome: RunOutcome.running));
    _serverSubscription = serverExecutor
        .analyze(request)
        .listen(
          (event) => state = state.copyWith(server: _sideProgressFor(event)),
          onError: (Object error) => state = state.copyWith(
            server: SideProgress(
              outcome: RunOutcome.failed,
              lastEvent: AnalysisEvent.failed(error: error),
            ),
          ),
        );
  }

  void _startLocal(AnalysisRequest request) {
    state = state.copyWith(local: const SideProgress(outcome: RunOutcome.running));
    _localSubscription = localExecutor
        .analyze(request)
        .listen(
          (event) => state = state.copyWith(local: _sideProgressFor(event)),
          onError: (Object error) => state = state.copyWith(
            local: SideProgress(
              outcome: RunOutcome.failed,
              lastEvent: AnalysisEvent.failed(error: error),
            ),
          ),
        );
  }

  /// Cancels whichever side(s) are still running. A side that already
  /// reached a terminal state (succeeded/failed) keeps that state - cancel
  /// never retroactively discards a completed result (規劃書 §6 Compare 路徑
  /// step 4 principle applied to cancellation too).
  Future<void> cancel() async {
    await _serverSubscription?.cancel();
    await _localSubscription?.cancel();
    await serverExecutor.cancel();
    await localExecutor.cancel();

    if (state.server.outcome == RunOutcome.running) {
      state = state.copyWith(server: const SideProgress(outcome: RunOutcome.cancelled));
    }
    if (state.local.outcome == RunOutcome.running) {
      state = state.copyWith(local: const SideProgress(outcome: RunOutcome.cancelled));
    }
  }

  /// Re-runs only the side(s) currently in [RunOutcome.failed], leaving a
  /// successful sibling untouched (規劃書 §6 V1 可用性限制: "Local 失敗時顯示
  /// 「重試 Local」或「切換 Server 並上傳影片」").
  Future<void> retryFailedSide() async {
    final request = state.lastRequest;
    if (request == null) return;
    if (state.server.outcome == RunOutcome.failed) {
      await _serverSubscription?.cancel();
      _startServer(request);
    }
    if (state.local.outcome == RunOutcome.failed) {
      await _localSubscription?.cancel();
      _startLocal(request);
    }
  }

  String _generateComparisonGroupId() {
    final random = Random();
    return List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  void dispose() {
    _serverSubscription?.cancel();
    _localSubscription?.cancel();
    if (localExecutor case DisposableAnalysisExecutor executor) {
      unawaited(executor.dispose());
    }
    super.dispose();
  }
}

final analysisRunControllerProvider =
    StateNotifierProvider<AnalysisRunController, AnalysisRunState>((ref) {
      return AnalysisRunController(
        serverExecutor: ServerAnalysisAdapter(backend: ref.watch(backendProvider)),
        localExecutor: LocalAnalysisAdapter(),
      );
    });
