import 'package:flutter/material.dart';
import 'package:frontend/utils/locale_provider.dart';

class VideoInfoPlaceholder extends StatelessWidget {
  const VideoInfoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final List<String> headers = [
      l10n.analysisStatus,
      l10n.runnerName,
      l10n.dateTime,
      l10n.cameraCount,
      l10n.fps,
      l10n.avgVelocity,
      l10n.avgAcceleration,
      l10n.avgStepLength,
      l10n.totalTime,
      l10n.notes,
    ];

    final List<String> values = [
      l10n.statusDone,
      l10n.runnerName,
      "YYYY-MM-DD HH:mm:ss",
      "{1, 2, 3, 4, 5}",
      "{30, 60}",
      l10n.avgVelocity,
      l10n.avgAcceleration,
      l10n.avgStepLength,
      l10n.totalTime,
      l10n.notes,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Table(
        border: const TableBorder(
          horizontalInside: BorderSide(width: 3, color: Colors.white), // 只要橫向分隔線
          verticalInside: BorderSide(width: 3, color: Colors.white),
          top: BorderSide.none, // 不要最上面
          bottom: BorderSide.none, // 不要最下面
          left: BorderSide.none, // 不要最左邊
          right: BorderSide.none, // 不要最右邊
        ),
        columnWidths: const {
          0: FixedColumnWidth(200), // Rep 欄固定 60px
          1: FlexColumnWidth(), // Error 欄自動填滿
        },
        children: [
          for (int i = 0; i < headers.length; i++)
            // 表格內容
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    headers[i],
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, // 單行，不換行
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    values[i],
                    textAlign: TextAlign.center,
                    softWrap: true, // 允許換行
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
