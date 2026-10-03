import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/entities/upload_video_file.dart';
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

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          spacing: 16,
          children: [
            DateTimeSelectionWidget(
              onDateSelected: (date) {
                formNotifier.state = formData.copyWith(selectedDate: date);
              },
              onTimeSelected: (time) {
                formNotifier.state = formData.copyWith(selectedTime: time);
              },
              onCameraCountSelected: (cameraCount) {
                ref
                    .read(uploadAllControllerProvider.notifier)
                    .setCameraCount(cameraCount);
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
                  alignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: spacing,
                  children: List.generate(state.cameraCount, (index) {
                    return GestureDetector(
                      onTap: state.tempVideoStates[index].isUploading
                          ? null
                          : () async {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                    type: FileType.video,
                                    withData: true,
                                  );

                              if (result == null) return;

                              final file = result.files.first;

                              final uploadFile = UploadVideoFile(
                                bytes: file.bytes!,
                                filename: file.name,
                                mimeType:
                                    lookupMimeType(file.name) ?? 'video/mp4',
                              );

                              await ref
                                  .read(uploadAllControllerProvider.notifier)
                                  .uploadVideo(index, uploadFile);

                              if (!context.mounted) return;

                              // After upload, prompt anchor selection
                              final updatedState = ref.read(
                                uploadAllControllerProvider,
                              );
                              final thumbnailUrl = updatedState
                                  .tempVideoStates[index]
                                  .thumbnailUrl;
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
                              : state.tempVideoStates[index].thumbnailUrl !=
                                    null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Container(
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Image.network(
                                          state
                                              .tempVideoStates[index]
                                              .thumbnailUrl!,
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
                                          final thumbnailUrl = state
                                              .tempVideoStates[index]
                                              .thumbnailUrl!;
                                          final anchor =
                                              await showAnchorPointDialog(
                                                context: context,
                                                thumbnailUrl: thumbnailUrl,
                                                cameraIndex: index,
                                                initialAnchor: state
                                                    .tempVideoStates[index]
                                                    .anchorResult,
                                              );
                                          if (!context.mounted) return;
                                          ref
                                              .read(
                                                uploadAllControllerProvider
                                                    .notifier,
                                              )
                                              .setAnchor(index, anchor);
                                        },
                                        child: _AnchorBadge(
                                          isSet:
                                              state
                                                  .tempVideoStates[index]
                                                  .anchorResult !=
                                              null,
                                        ),
                                      ),
                                    ),
                                  ],
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
                if (state.tempVideoStates.any((e) => e.thumbnailUrl == null)) {
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

/// Badge shown on top of the thumbnail to indicate anchor status
class _AnchorBadge extends StatelessWidget {
  final bool isSet;

  const _AnchorBadge({required this.isSet});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSet
            ? const Color(0xFF00BFA5).withValues(alpha: 0.9)
            : Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSet ? const Color(0xFF00BFA5) : Colors.white24,
          width: 1,
        ),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
