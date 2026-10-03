class UnanalyzedRunSessionInfo {
  String runSessionId;
  String runnerId;
  String runnerName;
  DateTime date;
  int cameraCount;
  int fps;
  String note;
  List<int> unuploadedCameraIndexes;
  List<String?> videoPaths;

  UnanalyzedRunSessionInfo({
    required this.runSessionId,
    required this.runnerId,
    required this.runnerName,
    required this.date,
    required this.cameraCount,
    required this.fps,
    required this.note,
    required this.unuploadedCameraIndexes,
    required this.videoPaths,
  });

  factory UnanalyzedRunSessionInfo.fromJson(Map<String, dynamic> json) {
    return UnanalyzedRunSessionInfo(
      runSessionId: json['runSessionId'],
      runnerId: json['runnerId'],
      runnerName: json['runnerName'],
      date: DateTime.parse(json['date']),
      cameraCount: json['cameraCount'],
      fps: json['fps'],
      note: json['note'],
      unuploadedCameraIndexes: List<int>.from(json['unuploadedCameraIndexes']),
      videoPaths: List<String?>.from(json['videoPaths']),
    );
  }

  UnanalyzedRunSessionInfo copyWith({
    String? runSessionId,
    String? runnerId,
    String? runnerName,
    DateTime? date,
    int? cameraCount,
    int? fps,
    String? note,
    List<int>? unuploadedCameraIndexes,
    List<String?>? videoPaths,
  }) {
    return UnanalyzedRunSessionInfo(
      runSessionId: runSessionId ?? this.runSessionId,
      runnerId: runnerId ?? this.runnerId,
      runnerName: runnerName ?? this.runnerName,
      date: date ?? this.date,
      cameraCount: cameraCount ?? this.cameraCount,
      fps: fps ?? this.fps,
      note: note ?? this.note,
      unuploadedCameraIndexes: unuploadedCameraIndexes ?? this.unuploadedCameraIndexes,
      videoPaths: videoPaths ?? this.videoPaths,
    );
  }
}
