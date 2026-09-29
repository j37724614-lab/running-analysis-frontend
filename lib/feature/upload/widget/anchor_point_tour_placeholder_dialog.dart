import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/locale_provider.dart';

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

bool _isMobile(BuildContext context) {
  final isMobilePlatform =
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  final isShortScreen = MediaQuery.of(context).size.shortestSide < 600;
  return isMobilePlatform || isShortScreen;
}

/// A realistic Anchor Point Setting Dialog mockup shown during Guide Tour (Step 4)
class AnchorPointTourPlaceholderDialog extends StatefulWidget {
  final VoidCallback? onClose;

  const AnchorPointTourPlaceholderDialog({super.key, this.onClose});

  @override
  State<AnchorPointTourPlaceholderDialog> createState() => _AnchorPointTourPlaceholderDialogState();
}

class _AnchorPointTourPlaceholderDialogState extends State<AnchorPointTourPlaceholderDialog> {
  // Ground-truth real anchor points from running.db session cam1.mov
  final List<Offset> _pts = [
    const Offset(0.0914, 0.6612), // TL - 左上 (真實跑道左側遠端)
    const Offset(0.9147, 0.6504), // TR - 右上 (真實跑道右側遠端)
    const Offset(0.9706, 0.6598), // BR - 右下 (真實跑道右側近端)
    const Offset(0.0386, 0.6709), // BL - 左下 (真實跑道左側近端)
    const Offset(0.5037, 0.6558), // TM - 上中 (真實跑道中央遠端)
    const Offset(0.5036, 0.6654), // BM - 下中 (真實跑道中央近端)
  ];

  int? _draggingIdx;
  int? _selectedActivePointIdx;
  double _imgW = 1.0;
  double _imgH = 1.0;

  final TextEditingController _topCtrl = TextEditingController(text: '10.00');
  final TextEditingController _botCtrl = TextEditingController(text: '10.00');

  @override
  void dispose() {
    _topCtrl.dispose();
    _botCtrl.dispose();
    super.dispose();
  }

  Offset _norm(Offset local) =>
      Offset((local.dx / _imgW).clamp(0.0, 1.0), (local.dy / _imgH).clamp(0.0, 1.0));

  int? _nearestIdx(Offset norm) {
    int? best;
    double bestDist = double.infinity;
    for (int i = 0; i < _pts.length; i++) {
      final dx = (_pts[i].dx - norm.dx) * _imgW;
      final dy = (_pts[i].dy - norm.dy) * _imgH;
      final dist = dx * dx + dy * dy;
      if (dist < 28 * 28 && dist < bestDist) {
        bestDist = dist;
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A2035),
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
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
              l10n.anchorDialogTitle(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
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
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: _colors[i]),
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
              onPanStart: (d) {
                final touchNorm = _norm(d.localPosition);
                final idx = _nearestIdx(touchNorm);
                if (idx != null) {
                  setState(() {
                    _draggingIdx = idx;
                    if (_isMobile(context)) {
                      _selectedActivePointIdx = idx;
                    }
                  });
                }
              },
              onPanUpdate: (d) {
                if (_draggingIdx == null) return;
                setState(() {
                  _pts[_draggingIdx!] = _norm(d.localPosition);
                });
              },
              onPanEnd: (_) {
                setState(() {
                  _draggingIdx = null;
                });
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Realistic Runner Track Image ───────────
                  Positioned.fill(
                    child: Image.asset(
                      'assets/mock_runner_frame.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1E293B),
                        alignment: Alignment.center,
                        child: const Icon(Icons.videocam, size: 48, color: Colors.white38),
                      ),
                    ),
                  ),

                  // ── Quadrilateral perspective lines ─────────
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

                  // ── Drag hint label ───────────────────────
                  if (_draggingIdx == null)
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
                ],
              ),
            );
          },
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

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [field1, const SizedBox(height: 12), field2],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field1),
        const SizedBox(width: 12),
        Expanded(child: field2),
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
        ),
      ],
    );
  }

  Widget _buildAnchorPointButton(int i) {
    final labels = _getLabels(context);
    final isActive = _selectedActivePointIdx == i;
    final color = _colors[i];

    return InkWell(
      onTap: () {
        setState(() {
          _selectedActivePointIdx = i;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.25) : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color : color.withValues(alpha: 0.4),
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
                color: color,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check, size: 10, color: Colors.white),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                labels[i],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
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
          children: [
            Expanded(child: _buildAnchorPointButton(0)),
            const SizedBox(width: 8),
            Expanded(child: _buildAnchorPointButton(1)),
            const SizedBox(width: 8),
            Expanded(child: _buildAnchorPointButton(2)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildAnchorPointButton(3)),
            const SizedBox(width: 8),
            Expanded(child: _buildAnchorPointButton(4)),
            const SizedBox(width: 8),
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
                done: true,
                active: false,
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
          onPressed: () {},
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
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white54,
            side: const BorderSide(color: Colors.white12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.refresh, size: 16),
          label: Text(l10n.clear, style: const TextStyle(fontSize: 13)),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: widget.onClose,
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
      final drawLine = (int pA, int pB, Color color) {
        final isDragEdge = draggingIdx != null && (draggingIdx == pA || draggingIdx == pB);
        linePaint
          ..color = color.withValues(alpha: isDragEdge ? 1.0 : 0.75)
          ..strokeWidth = isDragEdge ? 2.5 : 2.0;
        canvas.drawLine(pts[pA], pts[pB], linePaint);
      };

      // Top segment
      drawLine(0, 4, const Color(0xFF4FC3F7));
      drawLine(4, 1, const Color(0xFF81C784));

      // Right edge
      drawLine(1, 2, const Color(0xFFFFB74D));

      // Bottom segment
      drawLine(2, 5, const Color(0xFFFFCC80));
      drawLine(5, 3, const Color(0xFFE57373));

      // Left edge
      drawLine(3, 0, const Color(0xFF4FC3F7));

      // Center divider
      drawLine(4, 5, const Color(0xFFCE93D8));

      // Polygon fill shading
      final polyPath = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[4].dx, pts[4].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..lineTo(pts[5].dx, pts[5].dy)
        ..lineTo(pts[3].dx, pts[3].dy)
        ..close();

      final fillPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.06)
        ..style = PaintingStyle.fill;
      canvas.drawPath(polyPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _QuadPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.draggingIdx != draggingIdx;
  }
}
