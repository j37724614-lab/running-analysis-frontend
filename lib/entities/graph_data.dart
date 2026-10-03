class GraphSeries {
  String name; // "main" | "left" | "right"
  List<double> y;

  GraphSeries({required this.name, required this.y});

  factory GraphSeries.fromJson(Map<String, dynamic> json) {
    return GraphSeries(name: json['name'], y: List<double>.from(json['y']));
  }
}

class GraphData {
  String title;
  String yLabel;
  double yMin;
  double yMax;
  List<double> x; // shared x-axis for all series
  List<GraphSeries> series;
  String category; // "metrics" | "angles"

  GraphData({
    required this.title,
    required this.yLabel,
    required this.yMin,
    required this.yMax,
    required this.x,
    required this.series,
    this.category = 'metrics',
  });

  factory GraphData.fromJson(Map<String, dynamic> json) {
    return GraphData(
      title: json['title'],
      yLabel: json['yLabel'],
      yMin: (json['yMin'] as num).toDouble(),
      yMax: (json['yMax'] as num).toDouble(),
      x: List<double>.from(json['x']),
      series: (json['series'] as List).map((s) => GraphSeries.fromJson(s)).toList(),
      category: json['category'] ?? 'metrics',
    );
  }
}
