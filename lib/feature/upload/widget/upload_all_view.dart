import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/entities/upload_video_file.dart';
import 'package:frontend/feature/analysis/analysis_mode.dart';
import 'package:frontend/feature/analysis/analysis_request.dart';
import 'package:frontend/feature/analysis/analysis_run_controller.dart';
import 'package:frontend/feature/guide/guide_steps_factory.dart';
import 'package:frontend/feature/upload/upload_controller.dart';
import 'package:frontend/feature/upload/upload_provider.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';
import 'package:frontend/feature/upload/widget/upload_all_controller.dart';
import 'package:frontend/feature/upload/widget/date_time_selection_widget.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/utils/router.dart';
import 'package:frontend/widget/loading_icon.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:frontend/feature/upload/widget/upload_form_provider.dart';

class UploadAllView extends ConsumerStatefulWidget {
  const UploadAllView({super.key});

  @override
  ConsumerState<UploadAllView> createState() => _UploadAllViewState();
}

class _UploadAllViewState extends ConsumerState<UploadAllView> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(uploadAllControllerProvider);
    final runnerId = ref.watch(uploadSelectedRunnerIdProvider);
    final formData = ref.watch(uploadAllFormProvider);
    final formNotifier = ref.read(uploadAllFormProvider.notifier);
    final localEnabled = ref.watch(localAnalysisFeatureEnabledProvider);
    final compareEnabled = ref.watch(compareAnalysisFeatureEnabledProvider);
    final analysisMode = ref.watch(uploadAnalysisModeProvider);
    final analysisState = ref.watch(analysisRunControllerProvider);

    ref.listen(analysisRunControllerProvider, (previous, next) {
      if ((next.mode != AnalysisMode.local && next.mode != AnalysisMode.compare) ||
          next.local.outcome != RunOutcome.succeeded ||
          previous?.local.outcome == RunOutcome.succeeded) {
        return;
      }
      final runSessionId = next.local.runSessionId;
      if (runnerId == null || runSessionId == null || !context.mounted) return;
      ref.invalidate(runnerHistoryProvider(runnerId));
      context.goNamed(
        AppRoute.playback.name,
        queryParameters: {'runnerId': runnerId, 'videoId': runSessionId},
      );
    });

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          spacing: 16,
          children: [
            if (localEnabled)
              SegmentedButton<AnalysisMode>(
                segments: [
                  const ButtonSegment(value: AnalysisMode.server, label: Text('Server')),
                  const ButtonSegment(value: AnalysisMode.local, label: Text('Local')),
                  if (compareEnabled)
                    const ButtonSegment(value: AnalysisMode.compare, label: Text('Compare')),
                ],
                selected: {analysisMode},
                onSelectionChanged: analysisState.isRunning
                    ? null
                    : (selection) async {
                        await ref.read(uploadAllControllerProvider.notifier).clearVideos();
                        ref.read(uploadAnalysisModeProvider.notifier).state = selection.single;
                      },
              ),
            DateTimeSelectionWidget(
              key: GuideKeys.uploadConfigKey,
              onDateSelected: (date) {
                formNotifier.state = formData.copyWith(selectedDate: date);
              },
              onTimeSelected: (time) {
                formNotifier.state = formData.copyWith(selectedTime: time);
              },
              onCameraCountSelected: (cameraCount) {
                ref.read(uploadAllControllerProvider.notifier).setCameraCount(cameraCount);
              },
              onFpsSelected: (fps) {
                formNotifier.state = formData.copyWith(fps: fps);
              },
              onNoteSelected: (note) {
                formNotifier.state = formData.copyWith(note: note);
              },
              onLongJumpChanged: (isLongJump) {
                formNotifier.state = formData.copyWith(isLongJump: isLongJump);
              },
              selectedDate: formData.selectedDate,
              selectedTime: formData.selectedTime,
              selectedCameraCount: state.cameraCount,
              selectedFps: formData.fps,
              note: formData.note,
              isLongJump: formData.isLongJump,
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                int columns;
                if (width > 1100) {
                  columns = 3;
                } else if (width > 600) {
                  columns = 2;
                } else {
                  columns = 1;
                }
                final spacing = 12.0;
                final itemWidth = (width - spacing * (columns - 1)) / columns;
                final itemHeight = itemWidth * 9 / 16;

                return Wrap(
                  key: GuideKeys.uploadVideoKey,
                  alignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: spacing,
                  children: List.generate(state.cameraCount, (index) {
                    return GestureDetector(
                      onTap: state.tempVideoStates[index].isUploading
                          ? null
                          : () async {
                              final needsServerUpload = analysisMode != AnalysisMode.local;
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'mp4',
                                  'mov',
                                  'avi',
                                  'mkv',
                                  'webm',
                                  'm4v',
                                  '3gp',
                                  'flv',
                                  'wmv',
                                  'ts',
                                ],
                                withData: needsServerUpload,
                              );

                              if (result == null) return;

                              final file = result.files.first;

                              if (file.path == null && analysisMode != AnalysisMode.server) {
                                if (!context.mounted) return;
                                _showError(context, '這個檔案沒有可供 Local 分析使用的路徑。');
                                return;
                              }

                              if (analysisMode == AnalysisMode.local) {
                                try {
                                  await ref
                                      .read(uploadAllControllerProvider.notifier)
                                      .stageLocalVideo(
                                        index,
                                        path: file.path!,
                                        filename: file.name,
                                      );
                                } catch (error) {
                                  if (!context.mounted) return;
                                  _showError(context, '無法保存 Local 分析影片：$error');
                                }
                                return;
                              }

                              if (file.bytes == null) {
                                if (!context.mounted) return;
                                _showError(context, '無法讀取要上傳到 Server 的影片。');
                                return;
                              }

                              final uploadFile = UploadVideoFile(
                                bytes: file.bytes!,
                                filename: file.name,
                                mimeType: lookupMimeType(file.name) ?? 'video/mp4',
                              );

                              String? analysisPath = file.path;
                              if (analysisMode == AnalysisMode.compare) {
                                try {
                                  await ref
                                      .read(uploadAllControllerProvider.notifier)
                                      .stageLocalVideo(
                                        index,
                                        path: file.path!,
                                        filename: file.name,
                                      );
                                  analysisPath = ref
                                      .read(uploadAllControllerProvider)
                                      .tempVideoStates[index]
                                      .localPath;
                                } catch (error) {
                                  if (!context.mounted) return;
                                  _showError(context, '無法保存 Compare 的 Local 影片：$error');
                                  return;
                                }
                              }

                              await ref
                                  .read(uploadAllControllerProvider.notifier)
                                  .uploadVideo(index, uploadFile, localPath: analysisPath);

                              if (!context.mounted) return;

                              // After upload, prompt anchor selection
                              final updatedState = ref.read(uploadAllControllerProvider);
                              final thumbnailUrl = updatedState.tempVideoStates[index].thumbnailUrl;
                              if (thumbnailUrl != null) {
                                final anchor = await showAnchorPointDialog(
                                  context: context,
                                  thumbnailUrl: thumbnailUrl,
                                  cameraIndex: index,
                                  initialAnchor: ref
                                      .read(uploadAllControllerProvider)
                                      .tempVideoStates[index]
                                      .anchorResult,
                                );
                                if (!context.mounted) return;
                                ref
                                    .read(uploadAllControllerProvider.notifier)
                                    .setAnchor(index, anchor);
                              }
                            },
                      child: SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: state.tempVideoStates[index].isUploading
                              ? const LoadingIcon()
                              : state.tempVideoStates[index].thumbnailUrl != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Container(
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Image.network(
                                          state.tempVideoStates[index].thumbnailUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Anchor status badge
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final thumbnailUrl =
                                              state.tempVideoStates[index].thumbnailUrl!;
                                          final anchor = await showAnchorPointDialog(
                                            context: context,
                                            thumbnailUrl: thumbnailUrl,
                                            cameraIndex: index,
                                            initialAnchor:
                                                state.tempVideoStates[index].anchorResult,
                                          );
                                          if (!context.mounted) return;
                                          ref
                                              .read(uploadAllControllerProvider.notifier)
                                              .setAnchor(index, anchor);
                                        },
                                        child: _AnchorBadge(
                                          key: index == 0 ? GuideKeys.uploadAnchorKey : null,
                                          isSet: state.tempVideoStates[index].anchorResult != null,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : state.tempVideoStates[index].isSelected
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      state.tempVideoStates[index].filename!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    '${l10n.camera} ${index + 1}\n${l10n.clickToUpload}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            if (analysisMode != AnalysisMode.server && analysisState.isRunning)
              Column(
                children: [
                  if (analysisMode == AnalysisMode.compare)
                    _AnalysisSideProgress(label: 'Server', progress: analysisState.server),
                  _AnalysisSideProgress(label: 'Local', progress: analysisState.local),
                  TextButton(
                    onPressed: () => ref.read(analysisRunControllerProvider.notifier).cancel(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            if (analysisMode == AnalysisMode.local &&
                analysisState.local.outcome == RunOutcome.failed)
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    analysisState.local.lastEvent?.message ?? 'Local analysis failed',
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(analysisRunControllerProvider.notifier).retryFailedSide(),
                    child: const Text('Retry Local'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final switchToServer = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Switch to Server?'),
                          content: const Text(
                            'You will need to select the video again. It will then be uploaded '
                            'to the Server for analysis.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Switch'),
                            ),
                          ],
                        ),
                      );
                      if (switchToServer != true) return;
                      await ref.read(uploadAllControllerProvider.notifier).clearVideos();
                      ref.read(uploadAnalysisModeProvider.notifier).state = AnalysisMode.server;
                    },
                    child: const Text('Switch Server'),
                  ),
                ],
              ),
            ElevatedButton(
              key: GuideKeys.uploadSubmitKey,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(horizontal: 48),
              ),
              onPressed: () async {
                if (runnerId == null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: Text(l10n.pleaseSelectRunnerFirst),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.confirm),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                if (state.tempVideoStates.any((e) => !e.isSelected)) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: Text(l10n.pleaseUploadAllVideos),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.confirm),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                if (analysisMode != AnalysisMode.local &&
                    state.tempVideoStates.any((video) => video.tempVideoId == null)) {
                  _showError(context, '影片仍在上傳到 Server，請等上傳完成後再開始分析。');
                  return;
                }

                if (analysisMode != AnalysisMode.server) {
                  final request = AnalysisRequest(
                    runnerId: runnerId,
                    date: DateTime(
                      formData.selectedDate.year,
                      formData.selectedDate.month,
                      formData.selectedDate.day,
                      formData.selectedTime.hour,
                      formData.selectedTime.minute,
                    ),
                    cameraCount: state.cameraCount,
                    fps: formData.fps,
                    note: formData.note,
                    isLongJump: formData.isLongJump,
                    videos: state.tempVideoStates.indexed
                        .map(
                          (entry) => AnalysisVideoInput(
                            cameraIndex: entry.$1,
                            fps: formData.fps.toDouble(),
                            rotationDegrees: 0,
                            frameWidth: 0,
                            frameHeight: 0,
                            path: entry.$2.localPath,
                            file: entry.$2.uploadFile,
                            tempVideoId: entry.$2.tempVideoId,
                            anchors: entry.$2.anchorResult,
                          ),
                        )
                        .toList(growable: false),
                  );
                  await ref
                      .read(analysisRunControllerProvider.notifier)
                      .start(analysisMode, request);
                  return;
                }

                final videoId = await ref
                    .read(uploadControllerProvider.notifier)
                    .uploadAllInfo(
                      runnerId,
                      formData.selectedDate,
                      formData.selectedTime,
                      state.cameraCount,
                      formData.fps,
                      formData.note,
                      formData.isLongJump,
                      state.tempVideoStates
                          .map(
                            (e) => {
                              "tempVideoId": e.tempVideoId,
                              "anchors": e.anchorResult?.toJson(),
                            },
                          )
                          .toList(),
                    );

                if (videoId == null || !context.mounted) return;

                // Invalidate history to ensure we fetch the latest list
                ref.invalidate(runnerHistoryProvider(runnerId));
                context.goNamed(
                  AppRoute.playback.name,
                  queryParameters: {'runnerId': runnerId, 'videoId': videoId},
                );
              },
              child: Text(l10n.upload),
            ),
          ],
        ),
      ],
    );
  }
}

void _showError(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
    ),
  );
}

class _AnalysisSideProgress extends StatelessWidget {
  const _AnalysisSideProgress({required this.label, required this.progress});

  final String label;
  final SideProgress progress;

  @override
  Widget build(BuildContext context) {
    final stage = progress.lastEvent?.stage.name ?? progress.outcome.name;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!progress.isTerminal) ...[
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 10),
          ],
          SizedBox(width: 64, child: Text(label)),
          Text(stage),
        ],
      ),
    );
  }
}

/// Badge shown on top of the thumbnail to indicate anchor status
class _AnchorBadge extends StatelessWidget {
  final bool isSet;

  const _AnchorBadge({super.key, required this.isSet});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSet ? const Color(0xFF00BFA5).withValues(alpha: 0.9) : Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSet ? const Color(0xFF00BFA5) : Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSet ? Icons.my_location : Icons.location_off_outlined,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isSet ? l10n.anchorSet : l10n.setAnchor,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
