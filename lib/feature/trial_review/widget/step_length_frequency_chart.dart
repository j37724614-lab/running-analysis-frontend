import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/entities/step_data.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/feature/trial_review/widget/chart_card.dart';
import 'package:frontend/feature/trial_review/widget/playback_cursor.dart';

/// ① Step length + step frequency on one chart, x-axis = chronological step
/// rank (last step = on the board). fl_chart's LineChart has no native
/// dual-scale y-axis, so both series are normalized to a shared 0-1 range
/// and the left/right tick labels are mapped back to each series' real
/// value range independently. A dashed vertical line tracks whichever step
/// rank the CAM1-3 playback is currently at (see PlaybackCursor).
class StepLengthFrequencyChart extends StatelessWidget {
  final String runSessionId;
  final StepsData data;

  const StepLengthFrequencyChart({super.key, required this.runSessionId, required this.data});

  @override
  Widget build(BuildContext context) {
    final chronological = chronologicalSteps(data);
    final lengthSteps = chronological.where((step) => step.stepLengthM != null).toList();
    final cadenceSteps = chronological.where((step) => step.cadenceSpm != null).toList();
    if (lengthSteps.isEmpty && cadenceSteps.isEmpty) {
      return const ChartCard(
        title: '步幅 + 步頻',
        child: Center(child: Text('沒有步幅/步頻資料')),
      );
    }

    final lengths = lengthSteps.map((step) => step.stepLengthM!).toList();
    final cadences = cadenceSteps.map((step) => step.cadenceSpm!).toList();
    final lenMin = lengths.isEmpty ? 0.0 : lengths.reduce((a, b) => a < b ? a : b);
    final lenMax = lengths.isEmpty ? 1.0 : lengths.reduce((a, b) => a > b ? a : b);
    final cadMin = cadences.isEmpty ? 0.0 : cadences.reduce((a, b) => a < b ? a : b);
    final cadMax = cadences.isEmpty ? 1.0 : cadences.reduce((a, b) => a > b ? a : b);
    final lenSpan = (lenMax - lenMin).abs() < 1e-6 ? 1.0 : lenMax - lenMin;
    final cadSpan = (cadMax - cadMin).abs() < 1e-6 ? 1.0 : cadMax - cadMin;

    // x = this step's chronological rank (same numbering PlaybackCursor's
    // cursor line uses via stepRank()), not the filtered list's own
    // position -- steps missing stepLengthM/cadenceSpm (always at least the
    // very first step of the trial, which has no previous point to measure
    // from) get dropped from this plot but still occupy a rank, so using a
    // plain 1..N loop index here would drift the plotted points off of
    // wherever the cursor lands.
    final byRank = {
      for (final step in chronological) stepRank(chronological, step.stepIndex): step,
    };
    final lengthSpots = <FlSpot>[];
    final cadenceSpots = <FlSpot>[];
    for (final step in lengthSteps) {
      final rank = stepRank(chronological, step.stepIndex);
      final x = rank.toDouble();
      lengthSpots.add(FlSpot(x, (step.stepLengthM! - lenMin) / lenSpan));
    }
    for (final step in cadenceSteps) {
      final rank = stepRank(chronological, step.stepIndex);
      final x = rank.toDouble();
      cadenceSpots.add(FlSpot(x, (step.cadenceSpm! - cadMin) / cadSpan));
    }

    final lengthColor = Theme.of(context).primaryColorDark;
    const cadenceColor = Colors.orange;

    return ChartCard(
      title: '步幅 + 步頻（第幾步，越右越接近起跳板）',
      height: 260,
      legend: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lengthSpots.isNotEmpty) ...[
            legendDot(lengthColor),
            const SizedBox(width: 4),
            const Text('步幅 (m)', style: TextStyle(fontSize: 12)),
          ],
          if (lengthSpots.isNotEmpty && cadenceSpots.isNotEmpty) const SizedBox(width: 16),
          if (cadenceSpots.isNotEmpty) ...[
            legendDot(cadenceColor),
            const SizedBox(width: 4),
            const Text('步頻 (spm)', style: TextStyle(fontSize: 12)),
          ],
        ],
      ),
      child: PlaybackCursor(
        runSessionId: runSessionId,
        data: data,
        builder: (context, stepRank) => LineChart(
          LineChartData(
            minY: 0,
            maxY: 1,
            minX: 1,
            maxX: chronological.length.toDouble(),
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
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touched) => touched.map((spot) {
                  final isLength = spot.barIndex == 0;
                  final step = byRank[spot.x.round()];
                  if (step == null) return null;
                  final value = isLength ? step.stepLengthM : step.cadenceSpm;
                  if (value == null) return null;
                  return LineTooltipItem(
                    '${isLength ? "步幅" : "步頻"}: ${value.toStringAsFixed(2)}',
                    TextStyle(color: isLength ? lengthColor : cadenceColor, fontSize: 13),
                  );
                }).toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: lengthSpots,
                color: lengthColor,
                barWidth: 3,
                dotData: FlDotData(show: true),
              ),
              LineChartBarData(
                spots: cadenceSpots,
                color: cadenceColor,
                barWidth: 3,
                dotData: FlDotData(show: true),
              ),
            ],
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
                axisNameWidget: lengthSpots.isEmpty
                    ? const SizedBox.shrink()
                    : const Text('步幅 (m)', style: TextStyle(fontSize: 11)),
                sideTitles: SideTitles(
                  showTitles: lengthSpots.isNotEmpty,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    (value * lenSpan + lenMin).toStringAsFixed(2),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              rightTitles: AxisTitles(
                axisNameWidget: cadenceSpots.isEmpty
                    ? const SizedBox.shrink()
                    : const Text('步頻 (spm)', style: TextStyle(fontSize: 11)),
                sideTitles: SideTitles(
                  showTitles: cadenceSpots.isNotEmpty,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    (value * cadSpan + cadMin).toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
          ),
        ),
      ),
    );
  }
}
