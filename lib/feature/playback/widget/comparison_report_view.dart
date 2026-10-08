import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/entities/comparison_report.dart';
import 'package:frontend/feature/playback/playback_provider.dart';

class ComparisonReportView extends ConsumerWidget {
  const ComparisonReportView({super.key, required this.comparisonGroupId});

  final String comparisonGroupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(comparisonReportProvider(comparisonGroupId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: report.when(
          loading: () => const Row(
            children: [
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('正在等待 Server / Local 比較報告…'),
            ],
          ),
          error: (_, __) => Row(
            children: [
              const Expanded(child: Text('比較報告尚未產生，Server 分析可能仍在進行。')),
              TextButton.icon(
                onPressed: () => ref.invalidate(comparisonReportProvider(comparisonGroupId)),
                icon: const Icon(Icons.refresh),
                label: const Text('重新整理'),
              ),
            ],
          ),
          data: (value) => _ReportContents(report: value),
        ),
      ),
    );
  }
}

class _ReportContents extends StatelessWidget {
  const _ReportContents({required this.report});

  final ComparisonReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Server / Local 比較', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('狀態：${report.status}　輸入一致：${report.inputHashesMatch ? "是" : "否"}'),
        if (report.serverDurationSeconds != null || report.localDurationSeconds != null)
          Text(
            'Server ${_seconds(report.serverDurationSeconds)}　'
            'Local ${_seconds(report.localDurationSeconds)}　'
            '倍率 ${report.localToServerRatio?.toStringAsFixed(2) ?? "—"}×',
          ),
        const Divider(),
        for (final metric in report.metrics)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(
                  metric.withinTolerance == true ? Icons.check_circle : Icons.warning_amber,
                  size: 18,
                  color: metric.withinTolerance == true ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(metric.name)),
                Text('${metric.value?.toStringAsFixed(3) ?? "—"} ${metric.unit}'),
                const SizedBox(width: 8),
                Text('(門檻 ${metric.tolerance})'),
              ],
            ),
          ),
        for (final warning in report.warnings)
          Text(warning, style: const TextStyle(color: Colors.orange)),
      ],
    );
  }

  String _seconds(double? value) => value == null ? '—' : '${value.toStringAsFixed(2)}s';
}
