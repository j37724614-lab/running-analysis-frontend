import 'package:frontend/feature/analysis/analysis_event.dart';
import 'package:frontend/feature/analysis/analysis_request.dart';

/// The one seam the upload UI, progress screen, cancel button and result
/// navigation depend on - they never need to know whether a run is Server or
/// Local (規劃書 §4 "這個 seam 已有兩個真實 adapter...它讓上傳 UI、進度畫面、
/// 取消、錯誤處理與結果導頁只實作一次"). [ServerAnalysisAdapter] and
/// [LocalAnalysisAdapter] both implement this; [AnalysisRunController] picks
/// one (or both, for Compare) based on [AnalysisMode].
abstract interface class AnalysisExecutor {
  /// Starts (or resumes watching) the analysis described by [request] and
  /// emits progress until a terminal [AnalysisStage.completed] or
  /// [AnalysisStage.failed] event. Implementations must not throw past the
  /// stream for an expected failure - emit [AnalysisEvent.failed] instead, so
  /// [AnalysisRunController] can tell apart cancellation.
  Stream<AnalysisEvent> analyze(AnalysisRequest request);

  /// Best-effort cancellation of whatever [analyze] call is in flight. Safe
  /// to call when nothing is running.
  Future<void> cancel();
}

abstract interface class DisposableAnalysisExecutor {
  Future<void> dispose();
}
