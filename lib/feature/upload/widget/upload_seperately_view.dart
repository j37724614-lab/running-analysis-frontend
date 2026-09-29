import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/upload_seperately_status.dart';
import 'package:frontend/entities/upload_video_file.dart';
import 'package:frontend/feature/guide/guide_steps_factory.dart';
import 'package:frontend/feature/upload/upload_controller.dart';
import 'package:frontend/feature/upload/upload_provider.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';
import 'package:frontend/feature/upload/widget/date_time_selection_widget.dart';
import 'package:frontend/feature/upload/widget/unanalyzed_history_view.dart';
import 'package:frontend/feature/upload/widget/upload_seperately_controller.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/utils/router.dart';
import 'package:frontend/widget/loading_icon.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:frontend/feature/upload/widget/upload_form_provider.dart';
import 'package:frontend/feature/upload/widget/upload_enums.dart';

class UploadSeperatelyView extends ConsumerStatefulWidget {
  const UploadSeperatelyView({super.key});

  @override
  ConsumerState<UploadSeperatelyView> createState() => _UploadSeperatelyViewState();
}

class _UploadSeperatelyViewState extends ConsumerState<UploadSeperatelyView> {
  int _selectedCameraCount = 5;
  int _index = 0;
  List<int> unuploadedCameraIndexes = [0, 1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final runnerId = ref.watch(uploadSelectedRunnerIdProvider);
    final selectedVideoId = ref.watch(uploadSelectedRunSessionIdProvider);
    final externalSession = ref.watch(uploadExternalSessionInfoProvider);
    final selectedRunnerSource = ref.watch(uploadSeparatelyTypeProvider);
    final formData = ref.watch(uploadSeperatelyFormProvider);
    final formNotifier = ref.read(uploadSeperatelyFormProvider.notifier);
    final state = ref.watch(uploadSeperatelyControllerProvider);
    final controller = ref.read(uploadSeperatelyControllerProvider.notifier);

    ref.listen(uploadExternalSessionInfoProvider, (previous, next) {
      if (next != null) {
        setState(() {
          unuploadedCameraIndexes = next.unuploadedCameraIndexes;
          if (unuploadedCameraIndexes.isNotEmpty && !unuploadedCameraIndexes.contains(_index)) {
            _index = unuploadedCameraIndexes.first;
          }
        });
      }
    });

    final effectiveCameraIndexes = unuploadedCameraIndexes.isNotEmpty
        ? unuploadedCameraIndexes
        : (selectedRunnerSource == SperatedType.newOne
              ? List.generate(_selectedCameraCount, (i) => i)
              : [0, 1, 2, 3, 4]);
    final effectiveIndex = effectiveCameraIndexes.contains(_index)
        ? _index
        : effectiveCameraIndexes.first;

    final isRecordSelected =
        selectedRunnerSource == SperatedType.newOne ||
        (selectedVideoId != null || externalSession != null);

    return Column(
      spacing: 16,
      children: [
        CustomSlidingSegmentedControl<SperatedType>(
          key: GuideKeys.uploadSepTabsKey,
          initialValue: selectedRunnerSource,
          customSegmentSettings: CustomSegmentSettings(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(25),
          ),
          thumbDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(25),
          ),
          onValueChanged: (SperatedType? value) {
            if (value == null) return;
            ref.read(uploadSeparatelyTypeProvider.notifier).state = value;
            // 切換模式時重置上傳狀態（包含縮圖）
            ref.read(uploadSeperatelyControllerProvider.notifier).resetState();

            setState(() {
              if (value == SperatedType.newOne) {
                unuploadedCameraIndexes = List.generate(_selectedCameraCount, (i) => i);
                _index = 0;
              } else {
                // 切換到選擇模式時，重置索引，具體索引會在選擇影片後更新
                _index = 0;
              }
            });
          },
          children: <SperatedType, Widget>{
            SperatedType.newOne: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.newRecord,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selectedRunnerSource == SperatedType.newOne
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            SperatedType.selectOne: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.selectRecord,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selectedRunnerSource == SperatedType.selectOne
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          },
        ),
        if (selectedRunnerSource == SperatedType.newOne)
          DateTimeSelectionWidget(
            key: GuideKeys.uploadConfigKey,
            selectedDate: formData.selectedDate,
            selectedTime: formData.selectedTime,
            selectedCameraCount: _selectedCameraCount,
            selectedFps: formData.fps,
            note: formData.note,
            onDateSelected: (date) {
              formNotifier.state = formData.copyWith(selectedDate: date);
            },
            onTimeSelected: (time) {
              formNotifier.state = formData.copyWith(selectedTime: time);
            },
            onCameraCountSelected: (cameraCount) {
              setState(() {
                _selectedCameraCount = cameraCount;
                if (selectedRunnerSource == SperatedType.newOne) {
                  unuploadedCameraIndexes = List.generate(cameraCount, (i) => i);
                  if (_index >= cameraCount) {
                    _index = 0;
                  }
                }
              });
            },
            onFpsSelected: (fps) {
              formNotifier.state = formData.copyWith(fps: fps);
            },
            onNoteSelected: (note) {
              formNotifier.state = formData.copyWith(note: note);
            },
          ),
        if (selectedRunnerSource == SperatedType.selectOne)
          Container(
            key: GuideKeys.uploadSepHistoryKey,
            child: UnanalyzedHistoryView(
              onVideoSelected: (video) {
                setState(() {
                  unuploadedCameraIndexes = video.unuploadedCameraIndexes;
                  if (unuploadedCameraIndexes.isNotEmpty) {
                    _index = unuploadedCameraIndexes.first;
                  }
                });
              },
            ),
          ),
        IgnorePointer(
          ignoring: !isRecordSelected,
          child: Opacity(
            opacity: isRecordSelected ? 1.0 : 0.45,
            child: Row(
              key: GuideKeys.uploadSepCameraKey,
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.cameraIndexNumber,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<int>(
                    hint: Row(
                      children: [
                        Text(
                          l10n.cameraCount,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    items: effectiveCameraIndexes
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: item,
                            child: Text(
                              '${l10n.camera} ${item + 1}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    value: effectiveIndex,
                    onChanged: isRecordSelected
                        ? (value) {
                            if (value != null) {
                              setState(() {
                                _index = value;
                              });
                            }
                          }
                        : null,
                    buttonStyleData: ButtonStyleData(
                      height: 36,
                      width: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        ),
                      ),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_forward_ios_outlined),
                      iconSize: 12,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                      scrollbarTheme: const ScrollbarThemeData(radius: Radius.circular(40)),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 36,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = (width > 600 ? 500.0 : width).clamp(240.0, 500.0);
            final itemHeight = itemWidth * 9 / 16;
            final spacing = 12.0;

            return IgnorePointer(
              ignoring: !isRecordSelected,
              child: Opacity(
                opacity: isRecordSelected ? 1.0 : 0.45,
                child: Wrap(
                  key: GuideKeys.uploadSepVideoKey,
                  spacing: spacing,
                  runSpacing: spacing,
                  alignment: WrapAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (!isRecordSelected || state.isUploading)
                          ? null // 未選取紀錄或上傳中不能再點
                          : () async {
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
                                withData: true,
                              );

                              if (result == null) return;

                              final file = result.files.first;

                              final uploadFile = UploadVideoFile(
                                bytes: file.bytes!,
                                filename: file.name,
                                mimeType: lookupMimeType(file.name) ?? 'video/mp4',
                              );

                              await controller.uploadVideo(effectiveIndex, uploadFile);

                              // After upload, prompt anchor selection
                              final updatedState = ref.read(uploadSeperatelyControllerProvider);
                              final thumbnailUrl = updatedState.thumbnail;
                              if (mounted && thumbnailUrl != null) {
                                final anchor = await showAnchorPointDialog(
                                  context: context,
                                  thumbnailUrl: thumbnailUrl,
                                  cameraIndex: effectiveIndex,
                                  initialAnchor: ref
                                      .read(uploadSeperatelyControllerProvider)
                                      .anchorResult,
                                );
                                ref
                                    .read(uploadSeperatelyControllerProvider.notifier)
                                    .setAnchor(anchor);
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
                          child: state.isUploading
                              ? const LoadingIcon()
                              : state.thumbnail != null
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
                                        child: Image.network(state.thumbnail!, fit: BoxFit.cover),
                                      ),
                                    ),
                                    // Anchor status badge
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final anchor = await showAnchorPointDialog(
                                            context: context,
                                            thumbnailUrl: state.thumbnail!,
                                            cameraIndex: effectiveIndex,
                                            initialAnchor: state.anchorResult,
                                          );
                                          ref
                                              .read(uploadSeperatelyControllerProvider.notifier)
                                              .setAnchor(anchor);
                                        },
                                        child: _AnchorBadge(isSet: state.anchorResult != null),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Text(
                                    '${l10n.camera} ${effectiveIndex + 1}\n${l10n.clickToUpload}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        ElevatedButton(
          key: GuideKeys.uploadSepSubmitKey,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Theme.of(context).primaryColor,
            disabledForegroundColor: Colors.black26,
            disabledBackgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 48),
          ),
          onPressed: !isRecordSelected
              ? null
              : () async {
                  final effectiveRunnerId = runnerId ?? externalSession?.runnerId;

                  if (selectedRunnerSource == SperatedType.newOne && effectiveRunnerId == null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Notice'),
                          content: Text(l10n.pleaseSelectRunnerFirst),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.confirm),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }
                  if (selectedRunnerSource == SperatedType.selectOne &&
                      (selectedVideoId == null || effectiveRunnerId == null)) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Notice'),
                          content: Text(l10n.pleaseSelectRecordToUpload),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.confirm),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }
                  if (state.thumbnail == null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text(l10n.selectVideoFirst),
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
                  UploadSeperatelyStatus? status;
                  if (selectedRunnerSource == SperatedType.newOne) {
                    status = await ref
                        .read(uploadControllerProvider.notifier)
                        .uploadSeperatelyNew(
                          effectiveRunnerId!,
                          formData.selectedDate,
                          formData.selectedTime,
                          _selectedCameraCount,
                          formData.fps,
                          formData.note,
                          effectiveIndex,
                          state.tempVideoId!,
                          state.anchorResult,
                        );
                  }
                  if (selectedRunnerSource == SperatedType.selectOne) {
                    status = await ref
                        .read(uploadControllerProvider.notifier)
                        .uploadSeperatelySelect(
                          effectiveRunnerId!,
                          selectedVideoId!,
                          effectiveIndex,
                          state.tempVideoId!,
                          state.anchorResult,
                        );
                  }
                  if (mounted && status != null) {
                    final runners = ref.read(uploadRunnerListProvider).value;
                    final isOwner =
                        runners != null && runners.any((r) => r.id == effectiveRunnerId);

                    if (runnerId != null) {
                      ref.invalidate(runnerUnanalyzedHistoryProvider(runnerId));
                    }

                    if (status.isAllUploaded == true) {
                      if (isOwner && effectiveRunnerId != null) {
                        ref.invalidate(runnerHistoryProvider(effectiveRunnerId));
                        if (mounted) {
                          context.goNamed(
                            AppRoute.playback.name,
                            queryParameters: {
                              'runnerId': effectiveRunnerId,
                              'videoId': status.runSessionId,
                            },
                          );
                        }
                      } else {
                        // External session completed
                        ref.read(uploadExternalSessionInfoProvider.notifier).state = null;
                        ref.read(uploadSelectedRunSessionIdProvider.notifier).state = null;
                        ref.read(uploadSeperatelyControllerProvider.notifier).resetState();
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(l10n.uploadSuccessNotice),
                                content: Text(l10n.allCamerasUploadedExternalNotice),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(l10n.confirm),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    } else {
                      setState(() {
                        unuploadedCameraIndexes = status!.unuploadedCameraIndexes;
                        if (unuploadedCameraIndexes.isNotEmpty) {
                          _index = unuploadedCameraIndexes.first;
                        }
                      });
                      final currentExternal = ref.read(uploadExternalSessionInfoProvider);
                      if (currentExternal != null &&
                          currentExternal.runSessionId == status.runSessionId) {
                        ref.read(uploadExternalSessionInfoProvider.notifier).state = currentExternal
                            .copyWith(unuploadedCameraIndexes: status.unuploadedCameraIndexes);
                      }
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Notice'),
                            content: Text(
                              '${l10n.pleaseUploadAllVideos}: ${status!.unuploadedCameraIndexes.map((e) => "${l10n.camera} ${e + 1}").join(', ')}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(uploadSeperatelyControllerProvider.notifier)
                                      .resetState();
                                  Navigator.of(context).pop();
                                },
                                child: Text(l10n.confirm),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
          child: Text(l10n.upload),
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
