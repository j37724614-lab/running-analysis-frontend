import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/locale_provider.dart';

// ── Data classes ──────────────────────────────────────────────

/// Normalised anchor point (x, y ∈ [0, 1])
class AnchorPoint {
  final double x;
  final double y;
  const AnchorPoint(this.x, this.y);

  @override
  String toString() => 'AnchorPoint($x, $y)';

  Map<String, double> toJson() => {'x': x, 'y': y};
}

/// Six image anchors plus the measured runway dimensions used for calibration.
class AnchorResult {
  final List<AnchorPoint> points;
  final double leftToMidDistanceM;
  final double midToRightDistanceM;
  final double runwayWidthM;

  const AnchorResult({
    required this.points,
    required this.leftToMidDistanceM,
    required this.midToRightDistanceM,
    required this.runwayWidthM,
  });

  Map<String, dynamic> toJson() {
    final totalLengthM = leftToMidDistanceM + midToRightDistanceM;
    final worldCoordinates = <(double, double)>[
      (0, 0),
      (totalLengthM, 0),
      (totalLengthM, runwayWidthM),
      (0, runwayWidthM),
      (leftToMidDistanceM, 0),
      (leftToMidDistanceM, runwayWidthM),
    ];

    return {
      'points': points.asMap().entries.map((entry) {
        final pointJson = <String, double>{...entry.value.toJson()};
        if (points.length == 6) {
          final (worldX, worldY) = worldCoordinates[entry.key];
          pointJson['world_x_m'] = worldX;
          pointJson['world_y_m'] = worldY;
        }
        return pointJson;
      }).toList(),
      'leftToMidDistanceM': leftToMidDistanceM,
      'midToRightDistanceM': midToRightDistanceM,
    };
  }
}

// ── Styling constants ─────────────────────────────────────────

const _colors = [
  Color(0xFF4FC3F7), // 淺藍 – TL
  Color(0xFF81C784), // 淺綠 – TR
  Color(0xFFFFB74D), // 橘   – BR
  Color(0xFFE57373), // 紅   – BL
  Color(0xFFCE93D8), // 淺紫 – TM
  Color(0xFFFFCC80), // 淺橘 – BM
];

List<String> _getLabels(BuildContext context) {
  final l10n = context.l10n;
  return [l10n.point1, l10n.point2, l10n.point3, l10n.point4, l10n.point5, l10n.point6];
}

/// Hit-test radius for grabbing an existing anchor (logical pixels)
const _kHitRadius = 16.0;

/// Magnifier radius (logical pixels)
const _kMagRadius = 54.0;

/// Magnifier zoom factor
const _kMagZoom = 2.8;

// ── Public entry point ────────────────────────────────────────

Future<AnchorResult?> showAnchorPointDialog({
  required BuildContext context,
  required String thumbnailUrl,
  required int cameraIndex,
  AnchorResult? initialAnchor,
}) {
  return showDialog<AnchorResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AnchorPointDialog(
      thumbnailUrl: thumbnailUrl,
      cameraIndex: cameraIndex,
      initialAnchor: initialAnchor,
    ),
  );
}

// ── Dialog widget ─────────────────────────────────────────────

class _AnchorPointDialog extends StatefulWidget {
  final String thumbnailUrl;
  final int cameraIndex;
  final AnchorResult? initialAnchor;

  const _AnchorPointDialog({
    required this.thumbnailUrl,
    required this.cameraIndex,
    this.initialAnchor,
  });

  @override
  State<_AnchorPointDialog> createState() => _AnchorPointDialogState();
}

class _AnchorPointDialogState extends State<_AnchorPointDialog>
    with SingleTickerProviderStateMixin {
  // Anchor points (normalised 0–1)
  final List<Offset> _pts = [];

  // Slide ratios for TM (point 5) and BM (point 6) along their segments
  double _t5 = 0.5;
  double _t6 = 0.5;

  // Drag / magnifier state
  int? _draggingIdx;
  Offset? _magPos; // normalised position shown in magnifier
  Offset? _panStartTouchNorm;
  Offset? _panStartAnchorPos;

  // Active anchor point index to set via tap
  int? _selectedActivePointIdx;

  // Pending tap (set in onTapDown, consumed in onTap)
  Offset? _pendingTapNorm;

  // Cached image size set in LayoutBuilder
  double _imgW = 1.0;
  double _imgH = 1.0;

  // Distance inputs
  final _topCtrl = TextEditingController();
  final _botCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();

  // Pulse animation for "next point" badge
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    // Pre-load previous anchor result if available
    final prev = widget.initialAnchor;
    if (prev != null) {
      _pts.addAll(prev.points.map((p) => Offset(p.x, p.y)));
      _topCtrl.text = prev.leftToMidDistanceM.toString();
      _botCtrl.text = prev.midToRightDistanceM.toString();
      _widthCtrl.text = prev.runwayWidthM.toString();
      _selectedActivePointIdx = null;

      if (_pts.length == 6) {
        // Calculate _t5 (TM along TL-TR)
        final A5 = _pts[0];
        final B5 = _pts[1];
        final P5 = _pts[4];
        final AB5 = B5 - A5;
        final AP5 = P5 - A5;
        final lenSq5 = AB5.dx * AB5.dx + AB5.dy * AB5.dy;
        _t5 = lenSq5 > 0 ? ((AP5.dx * AB5.dx + AP5.dy * AB5.dy) / lenSq5).clamp(0.0, 1.0) : 0.5;

        // Calculate _t6 (BM along BL-BR)
        final A6 = _pts[3];
        final B6 = _pts[2];
        final P6 = _pts[5];
        final AB6 = B6 - A6;
        final AP6 = P6 - A6;
        final lenSq6 = AB6.dx * AB6.dx + AB6.dy * AB6.dy;
        _t6 = lenSq6 > 0 ? ((AP6.dx * AB6.dx + AP6.dy * AB6.dy) / lenSq6).clamp(0.0, 1.0) : 0.5;
      } else if (_pts.length == 4) {
        // Dynamic upgrade of legacy 4 points to 6 points
        final tm = Offset((_pts[0].dx + _pts[1].dx) / 2, (_pts[0].dy + _pts[1].dy) / 2);
        final bm = Offset((_pts[2].dx + _pts[3].dx) / 2, (_pts[2].dy + _pts[3].dy) / 2);
        _pts.add(tm);
        _pts.add(bm);
        _t5 = 0.5;
        _t6 = 0.5;
      }
    }
  }

  @override
  void dispose() {
    _topCtrl.dispose();
    _botCtrl.dispose();
    _widthCtrl.dispose();
    _pulse.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────

  bool get _full => _pts.length >= 4;
  int get _nextIdx => _pts.length;

  /// Normalise local position to [0, 1]
  Offset _norm(Offset local) =>
      Offset((local.dx / _imgW).clamp(0.0, 1.0), (local.dy / _imgH).clamp(0.0, 1.0));

  bool _isMobile(BuildContext context) {
    final isMobilePlatform =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final isShortScreen = MediaQuery.of(context).size.shortestSide < 600;
    return isMobilePlatform || isShortScreen;
  }

  int? _nearestIdx(Offset normPos) {
    int? best;
    double bestDist = double.infinity;
    for (int i = 0; i < _pts.length; i++) {
      final dx = (normPos.dx - _pts[i].dx) * _imgW;
      final dy = (normPos.dy - _pts[i].dy) * _imgH;
      final d = dx * dx + dy * dy;
      if (d < _kHitRadius * _kHitRadius && d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  void _updatePointPosition(int idx, Offset norm) {
    if (idx < 4) {
      if (idx < _pts.length) {
        _pts[idx] = norm;
      } else {
        while (_pts.length < idx) {
          _pts.add(norm);
        }
        _pts.add(norm);
      }
      if (_pts.length == 4) {
        final tm = Offset((_pts[0].dx + _pts[1].dx) / 2, (_pts[0].dy + _pts[1].dy) / 2);
        final bm = Offset((_pts[2].dx + _pts[3].dx) / 2, (_pts[2].dy + _pts[3].dy) / 2);
        _pts.add(tm);
        _pts.add(bm);
        _t5 = 0.5;
        _t6 = 0.5;
      } else if (_pts.length == 6) {
        _pts[4] = _pts[0] + (_pts[1] - _pts[0]) * _t5;
        _pts[5] = _pts[3] + (_pts[2] - _pts[3]) * _t6;
      }
    } else if (idx == 4 && _pts.length == 6) {
      final A = _pts[0];
      final B = _pts[1];
      final AB = B - A;
      final AP = norm - A;
      final abLenSq = AB.dx * AB.dx + AB.dy * AB.dy;
      double t = 0.5;
      if (abLenSq > 0) {
        t = (AP.dx * AB.dx + AP.dy * AB.dy) / abLenSq;
        t = t.clamp(0.0, 1.0);
      }
      _t5 = t;
      _pts[4] = A + AB * t;
    } else if (idx == 5 && _pts.length == 6) {
      final A = _pts[3];
      final B = _pts[2];
      final AB = B - A;
      final AP = norm - A;
      final abLenSq = AB.dx * AB.dx + AB.dy * AB.dy;
      double t = 0.5;
      if (abLenSq > 0) {
        t = (AP.dx * AB.dx + AP.dy * AB.dy) / abLenSq;
        t = t.clamp(0.0, 1.0);
      }
      _t6 = t;
      _pts[5] = A + AB * t;
    }
  }

  // ── Gesture handlers ───────────────────────────────────────

  void _onTapDown(TapDownDetails d) {
    _pendingTapNorm = _norm(d.localPosition);
  }

  void _onTap() {
    final pos = _pendingTapNorm;
    _pendingTapNorm = null;
    if (pos == null) return;

    if (_isMobile(context) && _selectedActivePointIdx != null) {
      setState(() {
        final idx = _selectedActivePointIdx!;
        _updatePointPosition(idx, pos);
        if (_pts.length < 4) {
          _selectedActivePointIdx = _pts.length;
        }
      });
    } else {
      if (_full) return;
      if (_nearestIdx(pos) != null) return;
      setState(() {
        _pts.add(pos);
        if (_pts.length == 4) {
          final tm = Offset((_pts[0].dx + _pts[1].dx) / 2, (_pts[0].dy + _pts[1].dy) / 2);
          final bm = Offset((_pts[2].dx + _pts[3].dx) / 2, (_pts[2].dy + _pts[3].dy) / 2);
          _pts.add(tm);
          _pts.add(bm);
          _t5 = 0.5;
          _t6 = 0.5;
        }
      });
    }
  }

  void _onPanStart(DragStartDetails d) {
    if (_pts.isEmpty && !_isMobile(context)) return;
    final touchNorm = _norm(d.localPosition);
    _panStartTouchNorm = touchNorm;

    if (_isMobile(context) && _selectedActivePointIdx != null) {
      final idx = _selectedActivePointIdx!;
      setState(() {
        if (idx < _pts.length) {
          _panStartAnchorPos = _pts[idx];
          _draggingIdx = idx;
          _magPos = _pts[idx];
        } else {
          _updatePointPosition(idx, touchNorm);
          _panStartAnchorPos = _pts[idx];
          _draggingIdx = idx;
          _magPos = _pts[idx];
        }
      });
    } else {
      final idx = _nearestIdx(touchNorm);
      if (idx != null) {
        setState(() {
          _panStartAnchorPos = _pts[idx];
          _draggingIdx = idx;
          _magPos = _pts[idx];
          if (_isMobile(context)) {
            _selectedActivePointIdx = idx;
          }
        });
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_draggingIdx == null || _panStartTouchNorm == null || _panStartAnchorPos == null) return;
    final currentTouch = _norm(d.localPosition);
    final delta = currentTouch - _panStartTouchNorm!;
    final newPos = Offset(
      (_panStartAnchorPos!.dx + delta.dx).clamp(0.0, 1.0),
      (_panStartAnchorPos!.dy + delta.dy).clamp(0.0, 1.0),
    );
    setState(() {
      _updatePointPosition(_draggingIdx!, newPos);
      _magPos = _pts[_draggingIdx!];
    });
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() {
      _draggingIdx = null;
      _magPos = null;
      _panStartTouchNorm = null;
      _panStartAnchorPos = null;
    });
  }

  // ── Confirm / utility ──────────────────────────────────────

  bool get _canConfirm {
    if (!_full) return false;
    final t = double.tryParse(_topCtrl.text);
    final b = double.tryParse(_botCtrl.text);
    final w = double.tryParse(_widthCtrl.text);
    return t != null && t > 0 && b != null && b > 0 && w != null && w > 0;
  }

  void _confirm() {
    final result = AnchorResult(
      points: _pts.map((o) => AnchorPoint(o.dx, o.dy)).toList(),
      leftToMidDistanceM: double.parse(_topCtrl.text),
      midToRightDistanceM: double.parse(_botCtrl.text),
      runwayWidthM: double.parse(_widthCtrl.text),
    );
    Navigator.of(context).pop(result);
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A2035),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProgressBar(),
                    const SizedBox(height: 12),

                    _buildImageArea(),
                    const SizedBox(height: 16),

                    if (_isMobile(context)) ...[
                      _buildAnchorPointButtons(),
                      const SizedBox(height: 16),
                    ],

                    _buildDistanceInputs(),
                    const SizedBox(height: 16),

                    _buildGuide(),
                    const SizedBox(height: 16),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-builders ───────────────────────────────────────────

  Widget _buildHeader() {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.anchorDialogTitle(widget.cameraIndex + 1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(null),
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: l10n.close,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: List.generate(4, (i) {
          final done = i < _pts.length;
          final active = i == _pts.length;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: done
                    ? _colors[i]
                    : active
                    ? _colors[i].withValues(alpha: 0.45)
                    : Colors.white12,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildImageArea() {
    final l10n = context.l10n;
    final labels = _getLabels(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: LayoutBuilder(
          builder: (_, constraints) {
            _imgW = constraints.maxWidth;
            _imgH = constraints.maxHeight;

            return GestureDetector(
              // Tap → add new point
              onTapDown: _onTapDown,
              onTap: _onTap,
              // Pan → drag existing point
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Background image ──────────────────────
                  Positioned.fill(
                    child: Image.network(
                      widget.thumbnailUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, prog) {
                        if (prog == null) return child;
                        return Container(
                          color: Colors.black26,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(color: Color(0xFF2979FF)),
                        );
                      },
                    ),
                  ),

                  // ── Dim overlay ───────────────────────────
                  if (!_full)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.07),
                        alignment: Alignment.center,
                        child: _pts.isEmpty
                            ? Text(
                                l10n.tapToMarkPoint,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              )
                            : null,
                      ),
                    ),

                  // ── Quadrilateral lines ───────────────────
                  if (_pts.length >= 2)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _QuadPainter(
                          points: _pts,
                          width: _imgW,
                          height: _imgH,
                          draggingIdx: _draggingIdx,
                        ),
                      ),
                    ),

                  // ── Anchor markers ────────────────────────
                  ..._pts.asMap().entries.map((e) {
                    final i = e.key;
                    final pt = e.value;
                    final isDragging = i == _draggingIdx;
                    final isActive = _isMobile(context) && i == _selectedActivePointIdx;
                    return Positioned(
                      left: pt.dx * _imgW,
                      top: pt.dy * _imgH,
                      child: _AnchorMarker(
                        label: labels[i],
                        color: _colors[i],
                        index: i + 1,
                        isDragging: isDragging,
                        isActive: isActive,
                      ),
                    );
                  }),

                  // ── Next-point badge ──────────────────────
                  if (!_full && _draggingIdx == null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, child) =>
                            Transform.scale(scale: _pulseAnim.value, child: child),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _colors[_nextIdx].withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Pt ${_nextIdx + 1}：${labels[_nextIdx]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ── Drag hint label ───────────────────────
                  if (_full && _draggingIdx == null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.open_with, size: 12, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              l10n.dragToAdjust,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_draggingIdx != null && _magPos != null) _buildMagnifier(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMagnifier() {
    final norm = _magPos!;
    final cx = norm.dx * _imgW;
    final cy = norm.dy * _imgH;
    const r = _kMagRadius;
    const zoom = _kMagZoom;

    // Position magnifier above the finger; keep it inside image bounds
    double left = cx - r;
    double top = cy - r * 2.6 - 8;

    // Clamp so magnifier stays within the SizedBox bounds
    left = left.clamp(0.0, _imgW - r * 2);
    top = top.clamp(0.0, _imgH - r * 2);

    // The image inside the magnifier is translated so that (cx, cy) lands at (r, r)
    final tx = r - cx * zoom;
    final ty = r - cy * zoom;

    final draggingColor = _draggingIdx != null ? _colors[_draggingIdx!] : Colors.white;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: r * 2,
        height: r * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: draggingColor, width: 2.5),
          boxShadow: [
            BoxShadow(color: draggingColor.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Zoomed image
            OverflowBox(
              minWidth: 0,
              minHeight: 0,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: Offset(tx, ty),
                child: SizedBox(
                  width: _imgW * zoom,
                  height: _imgH * zoom,
                  child: Image.network(widget.thumbnailUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            // Crosshair overlay
            Positioned.fill(
              child: CustomPaint(painter: _CrosshairPainter(color: draggingColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceInputs() {
    final l10n = context.l10n;
    final isMobile = _isMobile(context);

    final field1 = _buildDistanceField(
      label: l10n.distanceLeftToCenter,
      controller: _topCtrl,
      icon: Icons.straighten,
      color: const Color(0xFF4FC3F7),
    );

    final field2 = _buildDistanceField(
      label: l10n.distanceCenterToRight,
      controller: _botCtrl,
      icon: Icons.straighten,
      color: const Color(0xFFFFB74D),
    );

    final field3 = _buildDistanceField(
      label: l10n.runwayWidth,
      controller: _widthCtrl,
      icon: Icons.compare_arrows,
      color: const Color(0xFF81C784),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [field1, const SizedBox(height: 12), field2, const SizedBox(height: 12), field3],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Expanded(child: field1),
        Expanded(child: field2),
        Expanded(child: field3),
      ],
    );
  }

  Widget _buildDistanceField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: Icon(icon, size: 18, color: color),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: '0.00',
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildAnchorPointButton(int i) {
    final labels = _getLabels(context);
    final isSet = i < _pts.length;
    final isActive = _selectedActivePointIdx == i;
    final color = _colors[i];
    final isAvailable = i < 4 || _pts.length == 6;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.4,
      child: InkWell(
        onTap: isAvailable
            ? () {
                setState(() {
                  _selectedActivePointIdx = i;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.25)
                : (isSet ? color.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? color : (isSet ? color.withValues(alpha: 0.4) : Colors.white12),
              width: isActive ? 2 : 1.5,
            ),
            boxShadow: isActive
                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSet ? color : Colors.transparent,
                  border: Border.all(
                    color: isSet ? Colors.white : color.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: isSet
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  labels[i],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? Colors.white : (isSet ? Colors.white70 : Colors.white30),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnchorPointButtons() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectAnchorToMark,
          style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          spacing: 8,
          children: [
            Expanded(child: _buildAnchorPointButton(0)),
            Expanded(child: _buildAnchorPointButton(1)),
            Expanded(child: _buildAnchorPointButton(2)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            Expanded(child: _buildAnchorPointButton(3)),
            Expanded(child: _buildAnchorPointButton(4)),
            Expanded(child: _buildAnchorPointButton(5)),
          ],
        ),
      ],
    );
  }

  Widget _buildGuide() {
    final l10n = context.l10n;
    final labels = _getLabels(context);
    final isMobile = _isMobile(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white54, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isMobile ? l10n.guideDescriptionMobile : l10n.guideDescription,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (i) => _GuideStep(
                index: i + 1,
                label: labels[i],
                color: _colors[i],
                done: i < _pts.length,
                active: i == _draggingIdx,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final l10n = context.l10n;
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _pts.isEmpty
              ? null
              : () => setState(() {
                  if (_pts.length == 6) {
                    _pts.removeRange(3, 6);
                  } else {
                    _pts.removeLast();
                  }
                  _selectedActivePointIdx = _pts.length;
                }),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.undo, size: 16),
          label: Text(l10n.undo, style: const TextStyle(fontSize: 13)),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _pts.isEmpty
              ? null
              : () => setState(() {
                  _pts.clear();
                  _selectedActivePointIdx = 0;
                }),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white54,
            side: const BorderSide(color: Colors.white12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.refresh, size: 16),
          label: Text(l10n.clear, style: const TextStyle(fontSize: 13)),
        ),
        const Spacer(),
        AnimatedOpacity(
          opacity: _canConfirm ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: ElevatedButton.icon(
            onPressed: _canConfirm ? _confirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(
              l10n.confirmAnchor,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Anchor Marker ─────────────────────────────────────────────

class _AnchorMarker extends StatelessWidget {
  final String label;
  final Color color;
  final int index;
  final bool isDragging;
  final bool isActive;

  const _AnchorMarker({
    required this.label,
    required this.color,
    required this.index,
    this.isDragging = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = isDragging || isActive;
    final circleSize = highlight ? 34.0 : 28.0;

    return Transform.translate(
      offset: Offset(0, -circleSize / 2),
      child: FractionalTranslation(
        translation: const Offset(-0.5, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: highlight ? Colors.white : Colors.white70,
                  width: highlight ? 2.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: highlight ? 0.8 : 0.5),
                    blurRadius: highlight ? 14 : 8,
                    spreadRadius: highlight ? 3 : 1,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: highlight ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: highlight ? 1.0 : 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansTC',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guide Step ────────────────────────────────────────────────

class _GuideStep extends StatelessWidget {
  final int index;
  final String label;
  final Color color;
  final bool done;
  final bool active;

  const _GuideStep({
    required this.index,
    required this.label,
    required this.color,
    required this.done,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: active ? 30 : 26,
          height: active ? 30 : 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? color : Colors.transparent,
            border: Border.all(
              color: done || active ? color : color.withValues(alpha: 0.35),
              width: active ? 2.5 : 1.5,
            ),
            boxShadow: active
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)]
                : null,
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '$index',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: done || active ? color : Colors.white38,
            fontSize: 11,
            fontFamily: 'NotoSansTC',
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ── Quad Painter ──────────────────────────────────────────────

class _QuadPainter extends CustomPainter {
  final List<Offset> points;
  final double width;
  final double height;
  final int? draggingIdx;

  const _QuadPainter({
    required this.points,
    required this.width,
    required this.height,
    this.draggingIdx,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final pts = points.map((p) => Offset(p.dx * width, p.dy * height)).toList();

    final linePaint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (pts.length == 6) {
      // Draw lines for 6-point layout
      final drawLine = (int pA, int pB, Color color) {
        final isDragEdge = draggingIdx != null && (draggingIdx == pA || draggingIdx == pB);
        linePaint
          ..color = color.withValues(alpha: isDragEdge ? 1.0 : 0.75)
          ..strokeWidth = isDragEdge ? 2.5 : 2.0;
        canvas.drawLine(pts[pA], pts[pB], linePaint);
      };

      // Left boundary (BL - TL)
      drawLine(3, 0, _colors[3]);
      // Right boundary (TR - BR)
      drawLine(1, 2, _colors[1]);
      // Top boundary segment 1 (TL - TM)
      drawLine(0, 4, _colors[0]);
      // Top boundary segment 2 (TM - TR)
      drawLine(4, 1, _colors[0]);
      // Bottom boundary segment 1 (BR - BM)
      drawLine(2, 5, _colors[2]);
      // Bottom boundary segment 2 (BM - BL)
      drawLine(5, 3, _colors[2]);
      // Middle line (TM - BM)
      drawLine(4, 5, _colors[4]);

      // Semi-transparent fill of the entire quad area
      final path = Path()..addPolygon([pts[0], pts[1], pts[2], pts[3]], true);
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF2979FF).withValues(alpha: 0.08)
          ..style = PaintingStyle.fill,
      );
    } else {
      // Legacy / intermediate drawing (less than 6 points)
      for (int i = 0; i < pts.length - 1; i++) {
        final isDragEdge = draggingIdx != null && (i == draggingIdx || i + 1 == draggingIdx);
        linePaint
          ..color = _colors[i].withValues(alpha: isDragEdge ? 1.0 : 0.75)
          ..strokeWidth = isDragEdge ? 2.5 : 2.0;
        canvas.drawLine(pts[i], pts[i + 1], linePaint);
      }

      if (pts.length == 4) {
        final isDragEdge = draggingIdx != null && (draggingIdx == 3 || draggingIdx == 0);
        linePaint
          ..color = _colors[3].withValues(alpha: isDragEdge ? 1.0 : 0.75)
          ..strokeWidth = isDragEdge ? 2.5 : 2.0;
        canvas.drawLine(pts[3], pts[0], linePaint);

        // Semi-transparent fill
        final path = Path()..addPolygon(pts, true);
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF2979FF).withValues(alpha: 0.10)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QuadPainter old) =>
      old.points != points ||
      old.width != width ||
      old.height != height ||
      old.draggingIdx != draggingIdx;
}

// ── Crosshair Painter ─────────────────────────────────────────

class _CrosshairPainter extends CustomPainter {
  final Color color;
  const _CrosshairPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Gap around the center dot so lines don't overlap it
    const gapRadius = 5.0;
    const dotRadius = 3.5;
    const lineLength = 14.0;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Horizontal lines (left gap ← center → right gap)
    canvas.drawLine(Offset(cx - gapRadius - lineLength, cy), Offset(cx - gapRadius, cy), linePaint);
    canvas.drawLine(Offset(cx + gapRadius, cy), Offset(cx + gapRadius + lineLength, cy), linePaint);

    // Vertical lines
    canvas.drawLine(Offset(cx, cy - gapRadius - lineLength), Offset(cx, cy - gapRadius), linePaint);
    canvas.drawLine(Offset(cx, cy + gapRadius), Offset(cx, cy + gapRadius + lineLength), linePaint);

    // Colored center dot
    canvas.drawCircle(Offset(cx, cy), dotRadius, Paint()..color = color);
    // White ring around dot for contrast
    canvas.drawCircle(
      Offset(cx, cy),
      dotRadius,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_CrosshairPainter old) => old.color != color;
}
