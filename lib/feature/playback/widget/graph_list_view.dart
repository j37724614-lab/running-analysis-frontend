import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/backend/video_playback_state_provider.dart';
import 'package:frontend/entities/graph_data.dart';
import 'package:frontend/entities/video_playback.dart';
import 'package:frontend/feature/playback/placeholder/graph_list_placeholder.dart';
import 'package:frontend/feature/playback/playback_provider.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/feature/playback/shimmer/graph_list_shimmer.dart';
import 'package:frontend/widget/processing_progress_widget.dart';
import 'package:frontend/widget/rounded_box_widget.dart';

// ══════════════════════════════════════════════════════════════════════════════

class GraphListView extends ConsumerWidget {
  const GraphListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runnerId = ref.watch(playbackSelectedRunnerIdProvider);
    final videoId = ref.watch(playbackSelectedRunSessionIdProvider);
    if (runnerId == null || videoId == null) {
      return const GraphListPlaceholder();
    }

    final l10n = context.l10n;
    final videoInfo = ref.watch(videoInfoProvider(videoId));
    final videoPlayback = ref.watch(videoPlaybackStateProvider);

    return AsyncValueWidget(
      value: videoInfo,
      loading: const GraphListShimmer(),
      data: (info) {
        if (info.status == 'failed') {
          return ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const GraphListPlaceholder(),
                Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.5))),
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.noChartData,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.statusFailed,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          value: 1.0,
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (info.status == 'processing') {
          return Stack(
            alignment: Alignment.center,
            children: [
              const GraphListShimmer(),
              ProcessingProgressWidget(progress: info.progress),
            ],
          );
        }

        final graphData = ref.watch(graphDataProvider(videoId));

        return AsyncValueWidget(
          value: graphData,
          loading: const GraphListShimmer(),
          data: (List<GraphData> graphs) {
            final metricsGraphs = graphs.where((g) => g.category == 'metrics').toList();
            final anglesGraphs = graphs.where((g) => g.category == 'angles').toList();

            return Column(
              children: [
                RoundedBoxWidget(
                  child: _GraphSection(
                    title: l10n.tabOverallPerformance,
                    icon: Icons.speed_rounded,
                    graphs: metricsGraphs,
                    videoPlayback: videoPlayback,
                    initiallyExpanded: true,
                  ),
                ),
                const SizedBox(height: 8),
                RoundedBoxWidget(
                  child: _GraphSection(
                    title: l10n.tabJointAngles,
                    icon: Icons.accessibility_new_rounded,
                    graphs: anglesGraphs,
                    videoPlayback: videoPlayback,
                    initiallyExpanded: false,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── Collapsible section ───────────────────────────────────────────────────

class _GraphSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<GraphData> graphs;
  final VideoPlayback videoPlayback;
  final bool initiallyExpanded;

  const _GraphSection({
    required this.title,
    required this.icon,
    required this.graphs,
    required this.videoPlayback,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    if (graphs.isEmpty) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(icon, color: Colors.white70, size: 22),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white54,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: graphs.length,
            // The backend decides how many series each graph has:
            //   1 series  → single-line chart
            //   2 series  → paired left/right chart
            itemBuilder: (context, index) {
              final g = graphs[index];
              return g.series.length >= 2
                  ? _buildPairedChart(context, g)
                  : _buildSingleChart(context, g);
            },
          ),
        ],
      ),
    );
  }

  // ── shared helpers ──────────────────────────────────────────────────────

  int _currentIndex(List<FlSpot> spots) {
    final progress = videoPlayback.position / videoPlayback.duration;
    return (progress * (spots.length - 1)).floor().clamp(0, spots.length - 1);
  }

  List<VerticalLine> _secondTicks(BuildContext context, List<double> xValues) => [
    for (double x = 1.0; x <= (xValues.lastOrNull ?? 0); x += 1.0)
      VerticalLine(
        x: x,
        color: Theme.of(context).primaryColorDark.withAlpha(128),
        strokeWidth: 2,
        dashArray: [5, 5],
      ),
  ];

  String _localizeTitle(BuildContext context, String rawTitle) {
    final l10n = context.l10n;
    switch (rawTitle.toLowerCase().trim()) {
      case 'distance':
        return l10n.metricDistance;
      case 'velocity':
        return l10n.metricVelocity;
      case 'acceleration':
        return l10n.metricAcceleration;
      case 'knee angle':
        return l10n.chartKneeAngle;
      case 'hip angle':
        return l10n.chartHipAngle;
      case 'elbow flexion':
      case 'elbow flexion angle':
        return l10n.chartElbowFlexion;
      case 'pelvis-torso angle':
      case 'pelvis torso angle':
        return l10n.chartPelvisTorsoAngle;
      default:
        return rawTitle;
    }
  }

  String _localizeYLabel(BuildContext context, String rawYLabel) {
    final l10n = context.l10n;
    final normalized = rawYLabel.toLowerCase().trim();
    if (normalized.startsWith('distance')) {
      return l10n.metricDistanceUnit;
    } else if (normalized.startsWith('velocity')) {
      return l10n.metricVelocityUnit;
    } else if (normalized.startsWith('acceleration')) {
      return l10n.metricAccelerationUnit;
    } else if (normalized.startsWith('angle')) {
      return l10n.angleUnit;
    }
    return rawYLabel;
  }

  SideTitles _leftTitles(double yMax) => SideTitles(
    showTitles: true,
    interval: yMax > 10 ? 150 : 1,
    reservedSize: 35,
    getTitlesWidget: (value, meta) {
      if (meta.min > 10) {
        if ((meta.min - value).abs() < 1 && (meta.min - value).abs() != 0) {
          return const SizedBox.shrink();
        }
        if ((meta.max - value).abs() < 1 && (meta.max - value).abs() != 0) {
          return const SizedBox.shrink();
        }
      } else {
        if ((meta.min - value).abs() < 0.05 && (meta.min - value).abs() != 0) {
          return const SizedBox.shrink();
        }
        if ((meta.max - value).abs() < 0.05 && (meta.max - value).abs() != 0) {
          return const SizedBox.shrink();
        }
      }
      return Text(
        meta.max > 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(2),
        style: const TextStyle(color: Colors.white),
      );
    },
  );

  FlTitlesData _titlesData(BuildContext context, String yLabel, double yMax) => FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      axisNameSize: 32,
      axisNameWidget: Text(
        context.l10n.timeWithUnit,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      sideTitles: SideTitles(
        interval: 1.0,
        showTitles: true,
        getTitlesWidget: (value, meta) =>
            Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white)),
      ),
    ),
    leftTitles: AxisTitles(
      axisNameSize: 32,
      axisNameWidget: Text(yLabel, style: const TextStyle(color: Colors.white, fontSize: 16)),
      sideTitles: _leftTitles(yMax),
    ),
  );

  FlBorderData _borderData(BuildContext context) => FlBorderData(
    show: true,
    border: Border(
      bottom: BorderSide(color: Theme.of(context).primaryColorDark.withAlpha(128), width: 3),
    ),
  );

  Widget _chartContainer({
    required BuildContext context,
    required Widget titleWidget,
    required Widget chart,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 12, right: 24),
      child: Column(
        children: [
          titleWidget,
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  // ── 1 series → single-line chart ────────────────────────────────────────

  Widget _buildSingleChart(BuildContext context, GraphData graph) {
    final primaryColor = Theme.of(context).primaryColorDark;
    final y = graph.series.first.y;
    final spots = List.generate(y.length, (i) => FlSpot(graph.x[i].toDouble(), y[i]));
    final ci = _currentIndex(spots);
    final playedSpots = spots.sublist(0, ci + 1);

    // barIndex 0 = faded (unplayed), barIndex 1 = played
    final whiteLine = LineChartBarData(
      spots: spots,
      color: Colors.white.withValues(alpha: 0.5),
      barWidth: 3,
      dotData: const FlDotData(show: false),
    );
    final redLine = LineChartBarData(
      spots: playedSpots,
      color: primaryColor,
      barWidth: 4,
      dotData: const FlDotData(show: false),
    );

    final displayTitle = _localizeTitle(context, graph.title);
    final displayYLabel = _localizeYLabel(context, graph.yLabel);

    return _chartContainer(
      context: context,
      titleWidget: Text(
        displayTitle,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
      ),
      chart: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color.fromARGB(150, 48, 54, 47),
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                // barIndex 0 = faded (unplayed), 1 = played
                final isFaded = spot.barIndex == 0;
                // For the faded line, hide spots that are already played
                if (isFaded && spot.bar.spots.indexOf(spot) <= ci) return null;
                return LineTooltipItem(
                  '${spot.y}',
                  TextStyle(fontSize: 16, color: isFaded ? Colors.white : primaryColor),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [whiteLine, redLine],
          minY: graph.yMin,
          maxY: graph.yMax,
          clipData: const FlClipData.none(),
          extraLinesData: ExtraLinesData(verticalLines: _secondTicks(context, graph.x)),
          titlesData: _titlesData(context, displayYLabel, graph.yMax),
          borderData: _borderData(context),
        ),
      ),
    );
  }

  // ── 2 series → paired left/right chart ──────────────────────────────────

  Widget _buildPairedChart(BuildContext context, GraphData graph) {
    final l10n = context.l10n;
    final primaryColor = Theme.of(context).primaryColorDark;
    final leftY = graph.series[0].y; // name == "left"
    final rightY = graph.series[1].y; // name == "right"

    final leftSpots = List.generate(leftY.length, (i) => FlSpot(graph.x[i].toDouble(), leftY[i]));
    final rightSpots = List.generate(
      rightY.length,
      (i) => FlSpot(graph.x[i].toDouble(), rightY[i]),
    );

    final leftCI = _currentIndex(leftSpots);
    final rightCI = _currentIndex(rightSpots);

    final leftPlayed = leftSpots.sublist(0, leftCI + 1);
    final rightPlayed = rightSpots.sublist(0, rightCI + 1);

    // Faded "future" lines
    final leftFaded = primaryColor.withValues(alpha: 0.5);
    final rightFaded = Colors.white.withValues(alpha: 0.5);
    final leftFade = LineChartBarData(
      spots: leftSpots,
      color: leftFaded,
      barWidth: 3,
      dotData: const FlDotData(show: false),
    );
    final rightFade = LineChartBarData(
      spots: rightSpots,
      color: rightFaded,
      barWidth: 3,
      dotData: const FlDotData(show: false),
    );
    // Vivid "played" lines  (index 2 = leftLive, index 3 = rightLive in lineBarsData)
    final leftLive = LineChartBarData(
      spots: leftPlayed,
      color: primaryColor,
      barWidth: 4,
      dotData: const FlDotData(show: false),
    );
    final rightLive = LineChartBarData(
      spots: rightPlayed,
      color: Colors.white,
      barWidth: 4,
      dotData: const FlDotData(show: false),
    );

    final displayTitle = _localizeTitle(context, graph.title);
    final displayYLabel = _localizeYLabel(context, graph.yLabel);

    return _chartContainer(
      context: context,
      titleWidget: Column(
        children: [
          Text(
            displayTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(primaryColor),
              const SizedBox(width: 4),
              Text(l10n.legendLeft, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 16),
              _legendDot(Colors.white),
              const SizedBox(width: 4),
              Text(l10n.legendRight, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
      chart: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color.fromARGB(150, 48, 54, 47),
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                // barIndex: 0=leftFade, 1=rightFade, 2=leftLive, 3=rightLive
                final idx = spot.barIndex;
                final spotIdx = spot.bar.spots.indexOf(spot);

                // Faded bars: only show tooltip for unplayed region
                if (idx == 0 && spotIdx <= leftCI) return null;
                if (idx == 1 && spotIdx <= rightCI) return null;

                final isLeft = idx == 0 || idx == 2;
                final sideLabel = isLeft ? l10n.legendLeft : l10n.legendRight;
                return LineTooltipItem(
                  '$sideLabel: ${spot.y.toStringAsFixed(1)}°',
                  TextStyle(fontSize: 16, color: isLeft ? primaryColor : Colors.white),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [leftFade, rightFade, leftLive, rightLive],
          minY: graph.yMin,
          maxY: graph.yMax,
          clipData: const FlClipData.none(),
          extraLinesData: ExtraLinesData(verticalLines: _secondTicks(context, graph.x)),
          titlesData: _titlesData(context, displayYLabel, graph.yMax),
          borderData: _borderData(context),
        ),
      ),
    );
  }
}
