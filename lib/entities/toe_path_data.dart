class ToePoint {
  final double x;
  final double y;
  final double? worldXM;
  final double? worldYM;
  final double score;

  ToePoint({required this.x, required this.y, this.worldXM, this.worldYM, required this.score});

  factory ToePoint.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic v) => v == null ? null : (v as num).toDouble();
    return ToePoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      worldXM: asDouble(json['worldXM']),
      worldYM: asDouble(json['worldYM']),
      score: (json['score'] as num).toDouble(),
    );
  }
}

class ToePathFrame {
  final int seqFrame;
  final int origFrame;
  final double timeSec;
  final Map<String, ToePoint> points;

  ToePathFrame({
    required this.seqFrame,
    required this.origFrame,
    required this.timeSec,
    required this.points,
  });

  factory ToePathFrame.fromJson(Map<String, dynamic> json) {
    return ToePathFrame(
      seqFrame: json['seqFrame'] as int,
      origFrame: json['origFrame'] as int,
      timeSec: (json['timeSec'] as num).toDouble(),
      points: (json['points'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, ToePoint.fromJson(value as Map<String, dynamic>)),
      ),
    );
  }
}

class ToePathData {
  final List<String> keypointNames;
  final bool hasWorldCoords;
  final List<ToePathFrame> frames;

  ToePathData({required this.keypointNames, required this.hasWorldCoords, required this.frames});

  factory ToePathData.fromJson(Map<String, dynamic> json) {
    return ToePathData(
      keypointNames: (json['keypointNames'] as List).map((e) => e as String).toList(),
      hasWorldCoords: json['hasWorldCoords'] as bool? ?? false,
      frames: (json['frames'] as List)
          .map((e) => ToePathFrame.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
