import 'package:flutter/material.dart';
import 'package:frontend/feature/playback/placeholder/one_graph_placeholder_item.dart';
import 'package:frontend/utils/locale_provider.dart';

class GraphListPlaceholder extends StatelessWidget {
  const GraphListPlaceholder({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = [l10n.metricDistance, l10n.metricVelocity, l10n.metricAcceleration];
    final yLabels = [l10n.metricDistanceUnit, l10n.metricVelocityUnit, l10n.metricAccelerationUnit];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Theme.of(context).primaryColor,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.only(top: 8, bottom: 4, left: 12, right: 24),
          child: OneGraphPlaceholderItem(title: titles[index], yLabel: yLabels[index]),
        ),
      ),
    );
  }
}
