import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/run_session_info.dart';
import 'package:frontend/feature/playback/playback_provider.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/utils/download_helper/download_helper.dart';

class SessionActionsView extends ConsumerWidget {
  const SessionActionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final runnerId = ref.watch(playbackSelectedRunnerIdProvider);
    final videoId = ref.watch(playbackSelectedRunSessionIdProvider);

    if (runnerId == null || videoId == null) {
      return _buildActionsContent(context, l10n: l10n, isEnabled: false);
    }

    final videoInfo = ref.watch(videoInfoProvider(videoId));
    return AsyncValueWidget(
      value: videoInfo,
      loading: _buildActionsContent(context, l10n: l10n, isEnabled: false),
      data: (RunSessionInfo video) {
        if (video.status == 'processing') {
          return _buildActionsContent(context, l10n: l10n, isEnabled: false);
        }

        final isDone = video.status == 'done';

        return _buildActionsContent(
          context,
          l10n: l10n,
          isEnabled: isDone,
          onPdf: () async {
            final filename = "Runner_Analysis_Report_${video.runSessionId}.pdf";
            final backend = ref.read(backendProvider);
            final bytes = await backend.getRunSessionPdf(video.runSessionId);
            await saveBytesToFile(bytes, filename);
          },
          onCsv: () async {
            final filename = "angles_${video.runSessionId}.csv";
            final backend = ref.read(backendProvider);
            final bytes = await backend.getRunSessionCsv(video.runSessionId);
            await saveBytesToFile(bytes, filename);
          },
          onDelete: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.deleteSessionConfirmTitle),
                content: Text(l10n.deleteSessionConfirmMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(l10n.delete),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              if (!context.mounted) return;
              try {
                final backend = ref.read(backendProvider);
                await backend.deleteRunSession(video.runSessionId);

                final history = await backend.getRunnerHistory(video.runnerId);

                if (history.isNotEmpty) {
                  ref.read(playbackSelectedRunSessionIdProvider.notifier).state =
                      history.last.runSessionId;
                } else {
                  ref.read(playbackSelectedRunSessionIdProvider.notifier).state = null;
                }

                ref.invalidate(runnerHistoryProvider(video.runnerId));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
              }
            }
          },
        );
      },
    );
  }

  Widget _buildActionsContent(
    BuildContext context, {
    required dynamic l10n,
    required bool isEnabled,
    VoidCallback? onPdf,
    VoidCallback? onCsv,
    VoidCallback? onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Center(
            child: Text(
              l10n.actions,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Divider(color: Colors.white, thickness: 3.0, height: 3.0),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isEnabled ? onPdf : null,
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                      label: Text(
                        l10n.downloadPdfReport,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 121, 169, 234),
                        disabledBackgroundColor: Colors.white24,
                        disabledForegroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isEnabled ? onCsv : null,
                      icon: const Icon(Icons.table_chart, color: Colors.white, size: 18),
                      label: Text(
                        l10n.downloadCsvData,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[400],
                        disabledBackgroundColor: Colors.white24,
                        disabledForegroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: isEnabled ? onDelete : null,
                icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                label: Text(
                  l10n.deleteSessionConfirmTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor: Colors.white24,
                  disabledForegroundColor: Colors.white54,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
