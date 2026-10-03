import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/entities/step_data.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/feature/trial_review/widget/chart_card.dart';
import 'package:frontend/feature/trial_review/widget/playback_cursor.dart';

/// ③ Step-length-only comparison across multiple trials, one line per
/// trial, x-axis = each trial's own chronological step rank (last step =
/// on the board). The dashed playback cursor only applies to the currently
/// open trial (`currentRunSessionId`) -- comparison trials have no video
/// playing on this page, so there's nothing for their line to track.
class MultiTrialStepLengthChart extends StatelessWidget {
  final String currentRunSessionId;
  final Map<String, StepsData> trials;
  final Map<String, Color> trialColors;
  final Map<String, String> trialLabels;

  const MultiTrialStepLengthChart({
    super.key,
    required this.currentRunSessionId,
    required this.trials,
    required this.trialColors,
    required this.trialLabels,
  });

  @override
  Widget build(BuildContext context) {
    if (trials.isEmpty) {
      return const ChartCard(
        title: '多次試跳步幅比較',
        child: Center(child: Text('沒有有效步幅可供比較')),
      );
    }

    var maxRank = 1;
    final barsData = <LineChartBarData>[];
    for (final entry in trials.entries) {
      final chronological = chronologicalSteps(entry.value);
      final spots = <FlSpot>[];
      for (final step in chronological) {
        if (step.stepLengthM == null) continue;
        final rank = stepRank(chronological, step.stepIndex);
        if (rank > maxRank) maxRank = rank;
        spots.add(FlSpot(rank.toDouble(), step.stepLengthM!));
      }
      if (spots.isEmpty) continue;
      barsData.add(
        LineChartBarData(
          spots: spots,
          color: trialColors[entry.key] ?? Colors.grey,
          barWidth: entry.key == currentRunSessionId ? 3 : 2,
          dotData: FlDotData(show: true),
        ),
      );
    }

    if (barsData.isEmpty) {
      return const ChartCard(
        title: '多次試跳步幅比較',
        child: Center(child: Text('沒有有效步幅可供比較')),
      );
    }

    return ChartCard(
      title: '多次試跳步幅比較（第幾步，越右越接近起跳板）',
      legend: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        children: [
          for (final id in trials.keys)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                legendDot(trialColors[id] ?? Colors.grey),
                const SizedBox(width: 4),
                Text(trialLabels[id] ?? id, style: const TextStyle(fontSize: 12)),
              ],
            ),
        ],
      ),
      height: 260,
      child: PlaybackCursor(
        runSessionId: currentRunSessionId,
        data: trials[currentRunSessionId] ?? StepsData(steps: const []),
        builder: (context, stepRank) => LineChart(
          LineChartData(
            minX: 1,
            maxX: maxRank.toDouble(),
            extraLinesData: ExtraLinesData(
              verticalLines: [
                if (stepRank != null)
                  VerticalLine(
                    x: stepRank.toDouble(),
                    color: Colors.black54,
                    strokeWidth: 2,
                    dashArray: [4, 3],
                  ),
              ],
            ),
            lineBarsData: barsData,
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) =>
                      Text(value.toInt().toString(), style: const TextStyle(fontSize: 11)),
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: const Text('步幅 (m)', style: TextStyle(fontSize: 11)),
                sideTitles: SideTitles(showTitles: true, reservedSize: 36),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: true),
          ),
        ),
      ),
    );
  }
}
