class ComparisonMetric {
  const ComparisonMetric({
    required this.name,
    required this.value,
    required this.tolerance,
    required this.withinTolerance,
    required this.unit,
  });

  final String name;
  final double? value;
  final double tolerance;
  final bool? withinTolerance;
  final String unit;

  factory ComparisonMetric.fromJson(Map<String, dynamic> json) => ComparisonMetric(
    name: json['metric'] as String,
    value: (json['absolute_difference'] as num?)?.toDouble(),
    tolerance: (json['tolerance'] as num).toDouble(),
    withinTolerance: json['within_tolerance'] as bool?,
    unit: json['unit'] as String,
  );
}

class ComparisonReport {
  const ComparisonReport({
    required this.status,
    required this.inputHashesMatch,
    required this.metrics,
    required this.serverDurationSeconds,
    required this.localDurationSeconds,
    required this.localToServerRatio,
    required this.warnings,
  });

  final String status;
  final bool inputHashesMatch;
  final List<ComparisonMetric> metrics;
  final double? serverDurationSeconds;
  final double? localDurationSeconds;
  final double? localToServerRatio;
  final List<String> warnings;

  factory ComparisonReport.fromJson(Map<String, dynamic> json) {
    final performance = json['performance'] as Map<String, dynamic>;
    return ComparisonReport(
      status: json['status'] as String,
      inputHashesMatch: json['input_hashes_match'] as bool,
      metrics: (json['metric_differences'] as List<dynamic>)
          .map((item) => ComparisonMetric.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      serverDurationSeconds: (performance['server_duration_seconds'] as num?)?.toDouble(),
      localDurationSeconds: (performance['local_duration_seconds'] as num?)?.toDouble(),
      localToServerRatio: (performance['local_to_server_ratio'] as num?)?.toDouble(),
      warnings: (json['warnings'] as List<dynamic>).cast<String>(),
    );
  }
}
