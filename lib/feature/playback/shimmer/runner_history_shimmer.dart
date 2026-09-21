import 'package:flutter/material.dart';
import 'package:frontend/feature/playback/placeholder/runner_history_placeholder.dart';
import 'package:shimmer/shimmer.dart';

class RunnerHistoryShimmer extends StatelessWidget {
  const RunnerHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).primaryColorDark.withValues(alpha: 0.8),
            highlightColor: Colors.white,
            child: OneRunnerHistoryPlaceholder(),
          ),
        ),
      ),
    );
  }
}
