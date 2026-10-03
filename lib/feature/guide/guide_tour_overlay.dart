import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/feature/guide/guide_tour_model.dart';
import 'package:frontend/utils/locale_provider.dart';

class GuideTourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback? onFinish;
  final VoidCallback? onSkip;

  const GuideTourOverlay({super.key, required this.steps, this.onFinish, this.onSkip});

  static Future<void> show({
    required BuildContext context,
    required List<TourStep> steps,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) async {
    if (steps.isEmpty) return;

    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, _, __) =>
            GuideTourOverlay(steps: steps, onFinish: onFinish, onSkip: onSkip),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<GuideTourOverlay> createState() => _GuideTourOverlayState();
}

class _GuideTourOverlayState extends State<GuideTourOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late List<TourStep> _steps;
  int _currentIndex = 0;
  Rect? _targetRect;
  Rect? _lastTargetRect;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _steps = List<TourStep>.from(widget.steps);
    _currentIndex = 0;
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStep(_currentIndex);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateSteps(List<TourStep> newSteps, {int? jumpToIndex}) {
    if (!mounted) return;
    final targetIndex = (jumpToIndex != null && jumpToIndex >= 0 && jumpToIndex < newSteps.length)
        ? jumpToIndex
        : _currentIndex.clamp(0, newSteps.length - 1);
    setState(() {
      _steps = List<TourStep>.from(newSteps);
      _currentIndex = targetIndex;
    });
    _loadStep(targetIndex);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // When window size or device orientation changes, recalculate target bounds
    if (mounted) {
      setState(() {
        _targetRect = _calculateTargetRect(_steps[_currentIndex]);
      });
    }
  }

  Rect? _calculateTargetRect(TourStep step) {
    Rect? rect = step.targetRect;
    if (step.targetKey != null && step.targetKey!.currentContext != null) {
      final renderBox = step.targetKey!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize && renderBox.attached) {
        final offset = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        rect = offset & size;
      }
    }

    if (rect != null) {
      rect = Rect.fromLTRB(
        rect.left - step.padding.left,
        rect.top - step.padding.top,
        rect.right + step.padding.right,
        rect.bottom + step.padding.bottom,
      );
    }
    return rect;
  }

  Future<void> _loadStep(int index) async {
    if (index < 0 || index >= _steps.length) return;

    final step = _steps[index];
    if (step.onBeforeStep != null) {
      await step.onBeforeStep!();
    }
    if (!mounted) return;

    // If target is inside a scrollable view, smoothly scroll it into view
    if (step.targetKey?.currentContext != null) {
      try {
        final renderBox = step.targetKey!.currentContext!.findRenderObject() as RenderBox?;
        double alignment = 0.35; // Default comfortable positioning for normal-sized objects
        if (renderBox != null && renderBox.hasSize) {
          final screenHeight = MediaQuery.sizeOf(context).height;
          // ONLY for objects whose length is greater than or equal to the visible viewport height,
          // align to the very top (0.0) so the title/header is at the top!
          if (renderBox.size.height >= screenHeight) {
            alignment = 0.0;
          }
        }

        await Scrollable.ensureVisible(
          step.targetKey!.currentContext!,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          alignment: alignment,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );
      } catch (_) {
        // Ignored if target is not in a Scrollable
      }
      if (!mounted) return;
      // Allow frame and scroll physics to completely settle
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    final finalRect = _calculateTargetRect(step);
    setState(() {
      _currentIndex = index;
      _targetRect = finalRect;
    });
  }

  void _next() {
    final currentStep = _steps[_currentIndex];
    if (currentStep.onNextIndex != null) {
      final target = currentStep.onNextIndex!();
      if (target >= 0 && target < _steps.length) {
        _loadStep(target);
        return;
      }
    }
    if (_currentIndex < _steps.length - 1) {
      _loadStep(_currentIndex + 1);
    } else {
      _finish();
    }
  }

  void _prev() {
    final currentStep = _steps[_currentIndex];
    if (currentStep.onPrevIndex != null) {
      final target = currentStep.onPrevIndex!();
      if (target >= 0 && target < _steps.length) {
        _loadStep(target);
        return;
      }
    }
    if (_currentIndex > 0) {
      _loadStep(_currentIndex - 1);
    }
  }

  void _skip() {
    widget.onSkip?.call();
    Navigator.of(context).pop();
  }

  void _finish() {
    widget.onFinish?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenSize = MediaQuery.of(context).size;
    final currentStep = _steps[_currentIndex];
    final activeTargetRect = _calculateTargetRect(currentStep) ?? _targetRect;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            _next();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _prev();
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            _skip();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Darkened backdrop with smoothly morphing and pulsing cutout hole
            Positioned.fill(
              child: TweenAnimationBuilder<Rect?>(
                tween: RectTween(begin: _lastTargetRect ?? activeTargetRect, end: activeTargetRect),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, animatedRect, _) {
                  _lastTargetRect = animatedRect;
                  return AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _GuideHolePainter(
                          targetRect: animatedRect,
                          shape: currentStep.shape,
                          borderRadius: currentStep.borderRadius,
                          pulseProgress: _pulseAnimation.value,
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Tap blocker
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {}, // Prevent clicking underneath
              ),
            ),

            // Tooltip Card
            _buildTooltipCard(context, currentStep, screenSize, l10n, activeTargetRect),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltipCard(
    BuildContext context,
    TourStep step,
    Size screenSize,
    dynamic l10n,
    Rect? targetRect,
  ) {
    const cardMaxWidth = 360.0;
    const padding = 16.0;

    double cardLeft = (screenSize.width - cardMaxWidth) / 2;
    double cardTop = screenSize.height * 0.4;
    if (targetRect != null) {
      final rect = targetRect;
      final spaceAbove = rect.top;
      final spaceBelow = screenSize.height - rect.bottom;

      final spaceLeft = rect.left;
      final spaceRight = screenSize.width - rect.right;

      // Determine tooltip placement (left/right/top/bottom)
      if (step.tooltipPosition == TourTooltipPosition.left ||
          (step.tooltipPosition == TourTooltipPosition.auto &&
              spaceLeft > cardMaxWidth + 24 &&
              spaceAbove < 220 &&
              spaceBelow < 220)) {
        cardLeft = (rect.left - cardMaxWidth - 20).clamp(
          padding,
          screenSize.width - cardMaxWidth - padding,
        );
        cardTop = (rect.center.dy - 120).clamp(padding + 40, screenSize.height - 260);
      } else if (step.tooltipPosition == TourTooltipPosition.right ||
          (step.tooltipPosition == TourTooltipPosition.auto &&
              spaceRight > cardMaxWidth + 24 &&
              spaceAbove < 220 &&
              spaceBelow < 220)) {
        cardLeft = (rect.right + 20).clamp(padding, screenSize.width - cardMaxWidth - padding);
        cardTop = (rect.center.dy - 120).clamp(padding + 40, screenSize.height - 260);
      } else if (step.tooltipPosition == TourTooltipPosition.top ||
          (step.tooltipPosition == TourTooltipPosition.auto &&
              spaceAbove > spaceBelow &&
              spaceAbove > 220)) {
        cardTop = (rect.top - 240).clamp(padding + 40, screenSize.height - 240);
        cardLeft = (rect.center.dx - cardMaxWidth / 2).clamp(
          padding,
          screenSize.width - cardMaxWidth - padding,
        );
      } else {
        cardTop = (rect.bottom + 20).clamp(padding, screenSize.height - 250);
        cardLeft = (rect.center.dx - cardMaxWidth / 2).clamp(
          padding,
          screenSize.width - cardMaxWidth - padding,
        );
      }
    }

    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == _steps.length - 1;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: cardLeft,
      top: cardTop,
      width: cardMaxWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFA1E293B), Color(0xF00F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Column(
                key: ValueKey<int>(_currentIndex),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Step pill badge + Close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00B0FF), Color(0xFF00E676)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.tourStep(_currentIndex + 1, _steps.length),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                        tooltip: l10n.tourSkip,
                        onPressed: _skip,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title with Icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (step.icon != null) ...[
                        Icon(step.icon, color: const Color(0xFF38BDF8), size: 22),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          step.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Description
                  Text(
                    step.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  if (step.customActionWidget != null) ...[
                    const SizedBox(height: 12),
                    step.customActionWidget!(context, _updateSteps, _next),
                  ],

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      // Skip Button
                      TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white54,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        child: Text(l10n.tourSkip, style: const TextStyle(fontSize: 13)),
                      ),

                      const Spacer(),

                      // Previous Button
                      if (!isFirst)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: OutlinedButton(
                            onPressed: _prev,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            child: Text(
                              l10n.tourPrevious,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                      // Next / Finish Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF00B0FF)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLast ? l10n.tourFinish : l10n.tourNext,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isLast ? Icons.check : Icons.arrow_forward_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideHolePainter extends CustomPainter {
  final Rect? targetRect;
  final TourTargetShape shape;
  final double borderRadius;
  final double pulseProgress;

  _GuideHolePainter({
    required this.targetRect,
    required this.shape,
    required this.borderRadius,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    if (targetRect == null) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
      return;
    }

    // Clamp the target rect with a safe margin so the bounding box and glowing border are never clipped by the screen edges
    const safeMargin = 6.0;
    final safeRect = Rect.fromLTRB(
      targetRect!.left.clamp(safeMargin, size.width - safeMargin),
      targetRect!.top.clamp(safeMargin, size.height - safeMargin),
      targetRect!.right.clamp(safeMargin, size.width - safeMargin),
      targetRect!.bottom.clamp(safeMargin, size.height - safeMargin),
    );

    // Using evenOdd fillType ensures the target hole is 100% transparent and completely unpainted across all renderers
    final backgroundPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (shape == TourTargetShape.circle) {
      final radius = (safeRect.width > safeRect.height ? safeRect.width : safeRect.height) / 2;
      backgroundPath.addOval(Rect.fromCircle(center: safeRect.center, radius: radius));
    } else {
      backgroundPath.addRRect(RRect.fromRectAndRadius(safeRect, Radius.circular(borderRadius)));
    }

    // 1. Draw darkened backdrop strictly outside the hole
    canvas.drawPath(backgroundPath, backgroundPaint);

    // 2. Draw vibrant breathing animated neon glow aura around target (shines both inside and outside border)
    final glowSpread = 8.0 + (pulseProgress * 8.0);
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.55 + (pulseProgress * 0.4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 + (pulseProgress * 2.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSpread);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (shape == TourTargetShape.circle) {
      final radius = (safeRect.width > safeRect.height ? safeRect.width : safeRect.height) / 2;
      canvas.drawCircle(safeRect.center, radius, glowPaint);
      canvas.drawCircle(safeRect.center, radius, borderPaint);
    } else {
      final rrect = RRect.fromRectAndRadius(safeRect, Radius.circular(borderRadius));
      canvas.drawRRect(rrect, glowPaint);
      canvas.drawRRect(rrect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GuideHolePainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.shape != shape ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.pulseProgress != pulseProgress;
  }
}
