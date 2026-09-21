import 'package:flutter/material.dart';

enum TourTargetShape { roundedRect, circle, rect }

enum TourTooltipPosition { auto, top, bottom, left, right, center }

typedef TourUpdateStepsCallback = void Function(List<TourStep> newSteps, {int? jumpToIndex});

class TourStep {
  final GlobalKey? targetKey;
  final Rect? targetRect;
  final String title;
  final String description;
  final IconData? icon;
  final TourTargetShape shape;
  final double borderRadius;
  final EdgeInsets padding;
  final TourTooltipPosition tooltipPosition;
  final Future<void> Function()? onBeforeStep;
  final Widget Function(
    BuildContext context,
    TourUpdateStepsCallback updateSteps,
    VoidCallback next,
  )?
  customActionWidget;
  final int Function()? onNextIndex;
  final int Function()? onPrevIndex;

  TourStep({
    this.targetKey,
    this.targetRect,
    required this.title,
    required this.description,
    this.icon,
    this.shape = TourTargetShape.roundedRect,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(8.0),
    this.tooltipPosition = TourTooltipPosition.auto,
    this.onBeforeStep,
    this.customActionWidget,
    this.onNextIndex,
    this.onPrevIndex,
  });
}
