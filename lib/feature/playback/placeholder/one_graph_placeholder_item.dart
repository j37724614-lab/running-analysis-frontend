import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/locale_provider.dart';

class OneGraphPlaceholderItem extends StatelessWidget {
  const OneGraphPlaceholderItem({super.key, required this.title, required this.yLabel});
  final String title;
  final String yLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        Container(
          height: 200,
          padding: const EdgeInsets.only(right: 12),
          child: LineChart(
            LineChartData(
              lineTouchData: const LineTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 32,
                  axisNameWidget: Text(
                    l10n.timeWithUnit,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  sideTitles: const SideTitles(showTitles: true, reservedSize: 35),
                ),
                leftTitles: AxisTitles(
                  axisNameSize: 32,
                  axisNameWidget: Text(yLabel, style: TextStyle(color: Colors.white, fontSize: 16)),
                  sideTitles: SideTitles(showTitles: true, reservedSize: 35),
                ),
              ),
              minX: 0,
              maxX: 38,
              minY: 0,
              maxY: 14,
              extraLinesData: ExtraLinesData(
                verticalLines: [
                  // 這裡之後要換成畫面切換的時間
                  for (double x in [5, 10, 15, 20, 25, 30, 35])
                    VerticalLine(
                      x: x,
                      color: Theme.of(context).primaryColorDark.withAlpha(128),
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  color: Colors.white.withValues(alpha: 0.5),
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(2, 2),
                    FlSpot(4, 5),
                    FlSpot(6, 3),
                    FlSpot(8, 4),
                    FlSpot(9, 3),
                    FlSpot(11, 4),
                    FlSpot(15, 2),
                    FlSpot(18, 4),
                    FlSpot(20, 7),
                    FlSpot(21, 4),
                    FlSpot(24, 6),
                    FlSpot(25, 5),
                    FlSpot(27, 8),
                    FlSpot(31, 6),
                    FlSpot(34, 14),
                    FlSpot(38, 10),
                  ],
                  isCurved: true,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: Colors.white.withValues(alpha: 0.1)),
                ),
              ],
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).primaryColorDark.withAlpha(128),
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
