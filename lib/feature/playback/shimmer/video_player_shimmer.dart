import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VideoPlayerShimmer extends StatelessWidget {
  const VideoPlayerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        // 給外層一個基本底色，或者保留背景色
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 只有背景在做 Shimmer 閃爍
          Shimmer.fromColors(
            baseColor: Theme.of(context).primaryColorDark.withValues(alpha: 0.3),
            highlightColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          // Icon 放在 Shimmer 之上，不參與閃爍，這樣才看得清楚
          Icon(Icons.ondemand_video_rounded, size: 64, color: Colors.white.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}
