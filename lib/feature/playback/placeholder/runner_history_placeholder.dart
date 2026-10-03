import 'package:flutter/material.dart';

class RunnerHistoryPlaceholder extends StatelessWidget {
  const RunnerHistoryPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 4, // 顯示 4 個靜態骨架卡片
      itemBuilder: (context, index) {
        return Padding(
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
            child: OneRunnerHistoryPlaceholder(),
          ),
        );
      },
    );
  }
}

class OneRunnerHistoryPlaceholder extends StatelessWidget {
  const OneRunnerHistoryPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左側圓形圖示骨架 (與選了跑者後一樣是淡藍底色)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.directions_run, color: Theme.of(context).primaryColorDark, size: 20),
        ),
        const SizedBox(width: 12),
        // 中間文字欄位骨架
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期時間骨架 (使用主題淡藍色)
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              // 相機數量與圖示骨架 (使用主題淡藍色)
              Row(
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    size: 14,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 50,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // 右側狀態標籤骨架 (使用主題淡藍色)
        Container(
          width: 44,
          height: 18,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }
}
