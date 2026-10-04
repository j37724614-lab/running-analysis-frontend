class LocalAnalysisRunRef {
  const LocalAnalysisRunRef({required this.runSessionId, required this.analysisRunId});

  final String runSessionId;
  final String analysisRunId;

  factory LocalAnalysisRunRef.fromJson(Map<String, dynamic> json) => LocalAnalysisRunRef(
    runSessionId: json['runSessionId'] as String,
    analysisRunId: json['analysisRunId'] as String,
  );
}
