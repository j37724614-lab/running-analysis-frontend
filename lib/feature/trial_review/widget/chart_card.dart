import 'package:flutter/material.dart';

/// Shared card shell for the metrics-panel charts: a title, an optional
/// legend row underneath it, and the chart itself given a fixed height so
/// fl_chart/CustomPaint children (which need bounded constraints) lay out
/// correctly inside the panel's scroll view.
class ChartCard extends StatelessWidget {
  final String title;
  final Widget? legend;
  final double? height;
  final Widget child;

  const ChartCard({super.key, required this.title, this.legend, this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          if (legend != null) ...[const SizedBox(height: 6), legend!],
          const SizedBox(height: 8),
          if (height != null) SizedBox(height: height, child: child) else child,
        ],
      ),
    );
  }
}

/// A small colored circle used next to a legend label.
Widget legendDot(Color color) {
  return Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
