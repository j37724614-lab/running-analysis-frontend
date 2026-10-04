class RunSessionInfo {
  String runSessionId;
  String runnerId;
  String runnerName;
  DateTime date;
  int cameraCount;
  int fps;
  double? avgVelocity;
  double? avgAcceleration;
  double? avgStepLength;
  double? totalTime;
  String note;
  String status;
  int progress;
  List<String> computeLocations;

  RunSessionInfo({
    required this.runSessionId,
    required this.runnerId,
    required this.runnerName,
    required this.date,
    required this.cameraCount,
    required this.fps,
    this.avgVelocity,
    this.avgAcceleration,
    this.avgStepLength,
    this.totalTime,
    required this.note,
    required this.status,
    required this.progress,
    this.computeLocations = const [],
  });

  factory RunSessionInfo.fromJson(Map<String, dynamic> json) {
    return RunSessionInfo(
      runSessionId: json['runSessionId'],
      runnerId: json['runnerId'],
      runnerName: json['runnerName'],
      date: DateTime.parse(json['date']),
      cameraCount: json['cameraCount'],
      fps: json['fps'],
      avgVelocity: json['avgVelocity'],
      avgAcceleration: json['avgAcceleration'],
      avgStepLength: json['avgStepLength'],
      totalTime: json['totalTime'],
      note: json['note'],
      status: json['status'],
      progress: json['progress'] ?? 0,
      computeLocations: (json['computeLocations'] as List<dynamic>? ?? const [])
          .map((value) => value as String)
          .toList(growable: false),
    );
  }
}
