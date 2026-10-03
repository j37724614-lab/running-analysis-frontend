import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/entities/step_data.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/feature/trial_review/widget/chart_card.dart';
import 'package:frontend/feature/trial_review/widget/trial_video_controller.dart';

/// Bird's-eye "footprint trail" of real landing points along the runway,
/// styled to match the pipeline's own equal-scale schematic review video
/// (scripts/tools/render_schematic_topdown_review.py, "Footprint trail"
/// variant) rather than a generic scatter chart: dark runway backdrop,
/// fixed-size footprint glyphs (never stretched by zoom), connected by a
/// trail line in real chronological order.
///
/// X is each step's real along-track distance (`worldXM`) -- not step
/// order -- so stride-length differences show up as real spacing on
/// screen, the same way the video does. Both axes share one scale (an
/// "equal scale" render, like the reference script) so the runway is never
/// visually distorted.
///
/// Each camera can be calibrated to a different physical runway length, so
/// while synced to video playback the displayed range/scale switches to the
/// *active* camera's own footsteps instead of the combined span of all
/// cameras -- otherwise a short camera segment would look stretched (or a
/// long one squeezed) to match whichever camera happens to have the widest
/// span. With no playback controller (or when the active camera has no
/// steps of its own), it falls back to the combined overview across every
/// camera.
///
/// Requires 6-point homography calibration (worldXM/worldYM) -- 4-point
/// line-calibration sessions have no lateral coordinate and can't plot here.
class StepLateralPathChart extends StatelessWidget {
  final StepsData data;
  final TrialVideoPlaybackController? playbackController;

  const StepLateralPathChart({super.key, required this.data, this.playbackController});

  @override
  Widget build(BuildContext context) {
    final allPoints = _buildPoints(chronologicalSteps(data));

    if (allPoints.isEmpty) {
      return const ChartCard(
        title: '同步腳步俯視路徑（固定比例，公尺）',
        child: Center(child: Text('沒有可顯示的資料（需使用 6 點校正）')),
      );
    }

    final controller = playbackController;
    if (controller == null || controller.managers.isEmpty) {
      return _buildChart(
        allPoints: allPoints,
        visiblePoints: allPoints,
        syncLabel: '等待影片同步',
        runwayWidthM: _anyRunwayWidthM(data.runwayWidthByCam),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final activeIndex = controller.activeIndex.clamp(0, controller.managers.length - 1);
        final videoController = controller.managers[activeIndex].controller;
        return AnimatedBuilder(
          animation: videoController,
          builder: (context, _) {
            final visibleSteps = visibleStepsAtPlayback(
              data,
              activeCameraIndex: activeIndex,
              position: videoController.value.position,
            );
            // Scale/frame the runway to the active camera's own footsteps
            // -- each camera can be calibrated to a different physical
            // length, so reusing the combined span here would stretch or
            // squeeze this camera's segment to match the others. Fall back
            // to the combined overview if this camera has no steps of its
            // own to frame on.
            final cameraPoints = allPoints.where((p) => p.cam == activeIndex).toList();
            final scalePoints = cameraPoints.isEmpty ? allPoints : cameraPoints;
            final visiblePoints = cameraPoints.isEmpty
                ? _buildPoints(visibleSteps)
                : _buildPoints(visibleSteps.where((s) => s.cam == activeIndex));
            return _buildChart(
              allPoints: scalePoints,
              visiblePoints: visiblePoints,
              syncLabel:
                  'Cam ${activeIndex + 1} · ${_formatDuration(videoController.value.position)}',
              runwayWidthM:
                  data.runwayWidthByCam?[activeIndex] ?? _anyRunwayWidthM(data.runwayWidthByCam),
            );
          },
        );
      },
    );
  }

  /// Any one calibrated width, for the combined overview (no single active
  /// camera) or as a fallback when the active camera's own anchors are
  /// missing -- every camera calibrates the same physical lane, so any
  /// entry is the operator's real measurement, not a guess.
  double? _anyRunwayWidthM(Map<int, double>? byCam) =>
      byCam == null || byCam.isEmpty ? null : byCam.values.first;

  Widget _buildChart({
    required List<_LandingPoint> allPoints,
    required List<_LandingPoint> visiblePoints,
    required String syncLabel,
    double? runwayWidthM,
  }) {
    return ChartCard(
      title: '同步腳步俯視路徑（固定比例，公尺）',
      legend: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: [
          legendDot(_kLeftFootColor),
          const Text('左腳', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 10),
          legendDot(_kRightFootColor),
          const Text('右腳', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 10),
          const Icon(Icons.sync, size: 14),
          Text(syncLabel, style: const TextStyle(fontSize: 12)),
        ],
      ),
      height: 240,
      child: CustomPaint(
        size: Size.infinite,
        painter: _FootprintTrailPainter(
          allPoints: allPoints,
          visiblePoints: visiblePoints,
          runwayWidthM: runwayWidthM,
        ),
      ),
    );
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  List<_LandingPoint> _buildPoints(Iterable<StepSample> steps) {
    final result = <_LandingPoint>[];
    for (final step in steps) {
      final x = step.worldXM;
      final y = step.worldYM;
      final foot = step.foot;
      if (x == null || y == null || (foot != 'left' && foot != 'right')) {
        continue;
      }
      result.add(
        _LandingPoint(
          stepIndex: step.stepIndex,
          cam: step.cam,
          worldXM: x,
          worldYM: y,
          isLeft: foot == 'left',
          stepLengthM: step.stepLengthM,
        ),
      );
    }
    return result;
  }
}

class _LandingPoint {
  final int stepIndex;
  final int cam;
  final double worldXM;
  final double worldYM;
  final bool isLeft;
  final double? stepLengthM;

  _LandingPoint({
    required this.stepIndex,
    required this.cam,
    required this.worldXM,
    required this.worldYM,
    required this.isLeft,
    this.stepLengthM,
  });
}

// Colors lifted directly from the reference script's BGR literals
// (draw_footprint/draw_runway in render_schematic_topdown_review.py),
// converted to Flutter's ARGB.
const _kCanvasBg = Color(0xFF1F241C); // cv2 (28,36,31) BGR
const _kRunwayFill = Color(0xFFB14A40); // cv2 (64,74,177) BGR
const _kRunwayBorder = Color(0xFFF5F5F5); // cv2 (245,245,245) BGR
const _kCenterLine = Color(0xFFDCDCDC); // cv2 (220,220,220) BGR
const _kTick = Color(0xFFF0F0F0); // cv2 (240,240,240) BGR
const _kLeftFootColor = Color(0xFF2DAAFF); // cv2 (255,170,45) BGR
const _kRightFootColor = Color(0xFFFFDC3C); // cv2 (60,220,255) BGR
const _kTrailColor = Color(0xFFFAEB6E); // cv2 (110,235,250) BGR
const _kAxisLabelColor = Color(0xFFEBEBEB); // cv2 (235,235,235) BGR

/// The largest of these candidate spacings (metres) whose labels would still
/// overlap at [pxPerMeter], stepped down to the next one that fits -- so the
/// ruler gets finer (e.g. every 1m or 0.5m) once a camera's own short runway
/// segment is zoomed in, instead of always the same coarse 5m spacing the
/// full multi-camera overview needs.
double _pickMeterInterval(double pxPerMeter) {
  const candidatesM = [0.5, 1.0, 2.0, 5.0, 10.0, 20.0];
  const minLabelSpacingPx = 30.0;
  for (final candidate in candidatesM) {
    if (pxPerMeter * candidate >= minLabelSpacingPx) return candidate;
  }
  return candidatesM.last;
}

String _formatMeters(double valueM) {
  final rounded = (valueM * 10).round() / 10.0;
  final isWhole = rounded == rounded.roundToDouble();
  return '${isWhole ? rounded.toStringAsFixed(0) : rounded.toStringAsFixed(1)}m';
}

class _FootprintTrailPainter extends CustomPainter {
  final List<_LandingPoint> allPoints;
  final List<_LandingPoint> visiblePoints;
  final double? runwayWidthM;

  _FootprintTrailPainter({required this.allPoints, required this.visiblePoints, this.runwayWidthM});

  @override
  void paint(Canvas canvas, Size size) {
    final xs = allPoints.map((p) => p.worldXM);
    var minX = xs.reduce((a, b) => a < b ? a : b);
    var maxX = xs.reduce((a, b) => a > b ? a : b);
    // A little breathing room so points at the very edge (and their fixed-
    // size glyphs) aren't clipped against the runway border.
    const padM = 0.6;
    minX -= padM;
    maxX += padM;

    // The runway rectangle's height must be the operator's own exact
    // calibration width, not wherever these particular feet happened to
    // land -- otherwise the drawn band silently resizes between camera
    // switches (a handful of central footsteps vs. ones near the edge)
    // even though the printed width label stays the fixed real number,
    // which reads as the two contradicting each other. Every camera's
    // anchors place world Y on the same 0..runwayWidthM scale (see
    // AnchorResult.toJson() on the calibration screen), so that range is
    // the true, stable bounds; only fall back to the footsteps' own spread
    // when no calibration width is available at all.
    double minY, maxY;
    final width = runwayWidthM;
    if (width != null) {
      const widthPadM = 0.15;
      minY = -widthPadM;
      maxY = width + widthPadM;
    } else {
      final ys = allPoints.map((p) => p.worldYM);
      minY = ys.reduce((a, b) => a < b ? a : b) - padM * 0.4;
      maxY = ys.reduce((a, b) => a > b ? a : b) + padM * 0.4;
    }
    final spanX = (maxX - minX).abs() < 1e-6 ? 1.0 : maxX - minX;
    final spanY = (maxY - minY).abs() < 1e-6 ? 1.0 : maxY - minY;

    const leftGutter = 42.0;
    const bottomGutter = 34.0;
    const topPadding = 28.0;
    const rightPadding = 12.0;
    final availWidth = (size.width - leftGutter - rightPadding).clamp(1.0, double.infinity);
    final availHeight = (size.height - topPadding - bottomGutter).clamp(1.0, double.infinity);

    // Equal scale on both axes -- like the reference video, the runway is
    // never stretched. Whichever axis is the tighter fit sets the scale;
    // the plot area is then centered within the looser axis's slack.
    final pxPerMeter = (availWidth / spanX < availHeight / spanY)
        ? availWidth / spanX
        : availHeight / spanY;
    final plotWidth = spanX * pxPerMeter;
    final plotHeight = spanY * pxPerMeter;
    final plotLeft = leftGutter + (availWidth - plotWidth) / 2;
    final plotTop = topPadding + (availHeight - plotHeight) / 2;

    Offset toCanvas(double worldX, double worldY) {
      return Offset(
        plotLeft + (worldX - minX) * pxPerMeter,
        plotTop + (worldY - minY) * pxPerMeter,
      );
    }

    void drawText(
      String text,
      Offset position, {
      TextAlign align = TextAlign.left,
      Color color = _kAxisLabelColor,
      double fontSize = 10,
    }) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: color, fontSize: fontSize),
        ),
        textAlign: align,
        textDirection: TextDirection.ltr,
      )..layout();
      var origin = position;
      if (align == TextAlign.right) {
        origin = position.translate(-painter.width, 0);
      } else if (align == TextAlign.center) {
        origin = position.translate(-painter.width / 2, 0);
      }
      painter.paint(canvas, origin);
    }

    // Runway backdrop.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = _kCanvasBg);
    final runwayRect = Rect.fromPoints(toCanvas(minX, minY), toCanvas(maxX, maxY));
    canvas.drawRect(runwayRect, Paint()..color = _kRunwayFill);
    canvas.drawRect(
      runwayRect,
      Paint()
        ..color = _kRunwayBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final centerY = toCanvas(minX, (minY + maxY) / 2).dy;
    canvas.drawLine(
      Offset(runwayRect.left, centerY),
      Offset(runwayRect.right, centerY),
      Paint()
        ..color = _kCenterLine
        ..strokeWidth = 1,
    );

    // Both axes share one equal scale, so one interval works as the ruler
    // step for both: fine enough to read precisely, but never so fine that
    // labels overlap. Picks the smallest candidate spacing that still keeps
    // consecutive labels legibly apart at the current zoom level.
    final majorIntervalM = _pickMeterInterval(pxPerMeter);
    final minorIntervalM = majorIntervalM / 2;
    final showMinorTicks = pxPerMeter * minorIntervalM >= 6;

    // Along-track (length) ruler: minor ticks every half-interval, major
    // ticks labelled with the real distance in metres.
    if (showMinorTicks) {
      final minorStart = (minX / minorIntervalM).ceil();
      final minorEnd = (maxX / minorIntervalM).floor();
      for (var i = minorStart; i <= minorEnd; i++) {
        if (i % 2 == 0) continue; // whole multiples are drawn as major ticks
        final x = toCanvas(i * minorIntervalM, minY).dx;
        canvas.drawLine(
          Offset(x, runwayRect.bottom),
          Offset(x, runwayRect.bottom - 4.0),
          Paint()
            ..color = _kTick
            ..strokeWidth = 1.0,
        );
      }
    }
    final majorStart = (minX / majorIntervalM).ceil();
    final majorEnd = (maxX / majorIntervalM).floor();
    for (var i = majorStart; i <= majorEnd; i++) {
      final worldX = i * majorIntervalM;
      final x = toCanvas(worldX, minY).dx;
      canvas.drawLine(
        Offset(x, runwayRect.bottom),
        Offset(x, runwayRect.bottom - 10.0),
        Paint()
          ..color = _kTick
          ..strokeWidth = 1.5,
      );
      // Skip the label (keep the tick) when it would fall right where the
      // width dimension's line and label live, just left of the runway's
      // own left edge -- otherwise the two overlap and neither reads.
      if (x - runwayRect.left >= 18 || i > majorStart) {
        drawText(_formatMeters(worldX), Offset(x, runwayRect.top - 16), align: TextAlign.center);
      }
    }

    // Runway width: the operator's own calibration measurement (exact, as
    // typed in on the calibration screen), not a range inferred from where
    // feet happened to land -- drawn as a dimension line spanning the
    // runway's own left edge with its precise value labelled once.
    if (width != null) {
      final dimX = runwayRect.left - 16.0;
      final dimPaint = Paint()
        ..color = _kTick
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(dimX, runwayRect.top), Offset(dimX, runwayRect.bottom), dimPaint);
      for (final capY in [runwayRect.top, runwayRect.bottom]) {
        canvas.drawLine(Offset(dimX - 3, capY), Offset(dimX + 3, capY), dimPaint);
      }
      final label = TextPainter(
        text: TextSpan(
          text: '寬 ${width.toStringAsFixed(2)}m',
          style: const TextStyle(color: _kAxisLabelColor, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(dimX - 4, (runwayRect.top + runwayRect.bottom) / 2);
      canvas.rotate(-math.pi / 2);
      // After the -90° rotation, the text's own thickness (its layout
      // height) maps to screen-space +x, not its width -- painting at
      // -height (rather than 0) keeps the whole label to the left of the
      // dimension line instead of straddling it; -width/2 centres it along
      // the line's length as before.
      label.paint(canvas, Offset(-label.width / 2, -label.height));
      canvas.restore();
    }

    // Step-order ticks along the very bottom, one per landing point --
    // mirrors the reference video's chart_axes() step-order row.
    var previousX = double.negativeInfinity;
    for (var i = 0; i < visiblePoints.length; i++) {
      final p = visiblePoints[i];
      final x = toCanvas(p.worldXM, minY).dx;
      final crowded = (x - previousX).abs() < 13;
      previousX = x;
      drawText(
        '${p.stepIndex}',
        Offset(x, size.height - bottomGutter + (crowded && i.isOdd ? 12 : 2)),
        align: TextAlign.center,
        fontSize: 9,
      );
    }

    // Trail line through the real chronological landing sequence.
    if (visiblePoints.length >= 2) {
      final path = Path();
      for (var i = 0; i < visiblePoints.length; i++) {
        final offset = toCanvas(visiblePoints[i].worldXM, visiblePoints[i].worldYM);
        if (i == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = _kTrailColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    // Stride length between each landing and the one before it -- the same
    // `stepLengthM` shown on the step-length/frequency chart, placed at the
    // midpoint of the segment it measures so it reads as "this stride was
    // this long" rather than a generic distance label.
    for (var i = 1; i < visiblePoints.length; i++) {
      final length = visiblePoints[i].stepLengthM;
      if (length == null) continue;
      final from = toCanvas(visiblePoints[i - 1].worldXM, visiblePoints[i - 1].worldYM);
      final to = toCanvas(visiblePoints[i].worldXM, visiblePoints[i].worldYM);
      drawText(
        '${length.toStringAsFixed(2)}m',
        Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2 - 12),
        align: TextAlign.center,
        color: _kTrailColor,
        fontSize: 9,
      );
    }

    // Fixed-size footprint glyphs -- deliberately NOT scaled by pxPerMeter,
    // same principle as the reference video: a real footprint stays a
    // constant on-screen size regardless of how zoomed in/out the runway is.
    for (final p in visiblePoints) {
      final center = toCanvas(p.worldXM, p.worldYM);
      _drawFootprint(canvas, center, p.isLeft);
    }
  }

  void _drawFootprint(Canvas canvas, Offset center, bool isLeft) {
    final color = isLeft ? _kLeftFootColor : _kRightFootColor;
    final paint = Paint()..color = color;
    // A small fixed lateral nudge (matching the reference script) so a
    // left/right pair landing at nearly the same worldY don't fully
    // overlap on screen.
    final offsetY = isLeft ? -4.0 : 4.0;
    final sole = center.translate(0, offsetY);
    canvas.drawOval(Rect.fromCenter(center: sole, width: 20, height: 10), paint);
    // Toe dot, offset toward the direction of travel (+X).
    canvas.drawCircle(sole.translate(9, 0), 3, paint);
  }

  @override
  bool shouldRepaint(_FootprintTrailPainter old) =>
      old.allPoints != allPoints ||
      old.visiblePoints.length != visiblePoints.length ||
      old.runwayWidthM != runwayWidthM;
}
