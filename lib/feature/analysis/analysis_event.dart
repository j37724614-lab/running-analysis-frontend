/// Stage names an [AnalysisExecutor] reports progress through (規劃書 §4
/// "AnalysisEvent 統一表示 validating、prescan、tracking、pose2d、pose3d、gait、
/// export、sync、completed 與 failed"). The UI switches on [AnalysisEvent.stage]
/// for a progress label instead of inferring progress from a frame index
/// (規劃書 §4 "Flutter 不應以 frame index 猜測總進度").
enum AnalysisStage {
  validating,
  prescan,
  tracking,
  pose2d,
  pose3d,
  speed,
  gait,
  export,
  sync,
  completed,
  failed,
}

/// One progress update from an [AnalysisExecutor]. `progress` is a 0..1
/// fraction *within* the current stage when known, and null when the
/// adapter has no finer-grained signal than "this stage is in flight" -
/// callers must not treat a null progress as 0.
class AnalysisEvent {
  const AnalysisEvent({
    required this.stage,
    this.progress,
    this.message,
    this.runSessionId,
    this.bundlePath,
    this.errorCode,
    this.retriable,
    this.error,
  });

  final AnalysisStage stage;
  final double? progress;
  final String? message;

  /// Set once the backend has created/identified the RunSession this run
  /// belongs to, so the UI can navigate to it even before [stage] reaches
  /// [AnalysisStage.completed] (e.g. after Server upload finishes but server
  /// compute is still running).
  final String? runSessionId;

  /// Local filesystem path returned by RunnerAnalysisKit after atomic bundle
  /// finalization. It is a path, never the bundle bytes themselves.
  final String? bundlePath;

  final String? errorCode;
  final bool? retriable;

  /// Only meaningful when [stage] is [AnalysisStage.failed].
  final Object? error;

  factory AnalysisEvent.completed({String? runSessionId, String? bundlePath}) => AnalysisEvent(
    stage: AnalysisStage.completed,
    progress: 1.0,
    runSessionId: runSessionId,
    bundlePath: bundlePath,
  );

  factory AnalysisEvent.failed({
    required Object error,
    String? message,
    String? runSessionId,
    String? bundlePath,
    String? errorCode,
    bool? retriable,
  }) => AnalysisEvent(
    stage: AnalysisStage.failed,
    error: error,
    message: message,
    runSessionId: runSessionId,
    bundlePath: bundlePath,
    errorCode: errorCode,
    retriable: retriable,
  );
}
