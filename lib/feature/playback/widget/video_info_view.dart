import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/run_session_info.dart';
import 'package:frontend/feature/playback/placeholder/video_info_placeholder.dart';
import 'package:frontend/feature/playback/playback_provider.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/feature/playback/shimmer/video_info_shimmer.dart';
import 'package:intl/intl.dart';

import 'package:frontend/widget/processing_progress_widget.dart';

class VideoInfoView extends ConsumerWidget {
  const VideoInfoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runnerId = ref.watch(playbackSelectedRunnerIdProvider);
    final videoId = ref.watch(playbackSelectedRunSessionIdProvider);
    if (runnerId == null || videoId == null) {
      return const VideoInfoPlaceholder();
    }

    final l10n = context.l10n;
    final videoInfo = ref.watch(videoInfoProvider(videoId));
    return AsyncValueWidget(
      value: videoInfo,
      loading: const VideoInfoShimmer(),
      data: (RunSessionInfo video) {
        if (video.status == 'processing') {
          return Stack(
            alignment: Alignment.center,
            children: [
              const VideoInfoShimmer(),
              ProcessingProgressWidget(progress: video.progress),
            ],
          );
        }

        final statusText = video.status == 'failed'
            ? l10n.statusFailed
            : (video.status == 'processing' ? l10n.statusProcessing : l10n.statusDone);

        final List<MapEntry<String, String>> allInfo = [
          MapEntry(l10n.analysisStatus, statusText),
          MapEntry(l10n.runnerName, video.runnerName.toString()),
          MapEntry(l10n.dateTime, DateFormat('yyyy-MM-dd HH:mm').format(video.date)),
          MapEntry(l10n.cameraCount, video.cameraCount.toString()),
          MapEntry(l10n.fps, video.fps.toString()),
          MapEntry('${l10n.avgVelocity} (${l10n.unitMps})', video.avgVelocity?.toString() ?? ''),
          MapEntry(
            '${l10n.avgAcceleration} (${l10n.unitMps2})',
            video.avgAcceleration?.toString() ?? '',
          ),
          MapEntry(
            '${l10n.avgStepLength} (${l10n.unitMeters})',
            video.avgStepLength?.toString() ?? '',
          ),
          MapEntry('${l10n.totalTime} (${l10n.unitSeconds})', video.totalTime.toString()),
          MapEntry(l10n.notes, video.note.toString()),
        ];

        final validInfo = allInfo.where((e) => e.value != 'null' && e.value.isNotEmpty).toList();
        final List<String> headers = validInfo.map((e) => e.key).toList();
        final List<String> values = validInfo.map((e) => e.value).toList();

        return Table(
          border: TableBorder(
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
            // 表格內容
            for (int i = 0; i < headers.length; i++)
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
        );
      },
    );
  }
}
