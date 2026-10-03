import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/unanalyzed_run_session_info.dart';
import 'package:frontend/entities/upload_seperately_status.dart';
import 'package:frontend/entities/upload_video_file.dart';
import 'package:frontend/feature/upload/upload_controller.dart';
import 'package:frontend/feature/upload/upload_provider.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';
import 'package:frontend/feature/upload/widget/date_time_selection_widget.dart';
import 'package:frontend/feature/upload/widget/unanalyzed_history_view.dart';
import 'package:frontend/feature/upload/widget/upload_seperately_controller.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/utils/router.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/widget/loading_icon.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:frontend/feature/upload/widget/upload_form_provider.dart';
import 'package:frontend/feature/upload/widget/upload_enums.dart';

class UploadSeperatelyView extends ConsumerStatefulWidget {
  const UploadSeperatelyView({super.key});

  @override
  ConsumerState<UploadSeperatelyView> createState() =>
      _UploadSeperatelyViewState();
}

class _UploadSeperatelyViewState extends ConsumerState<UploadSeperatelyView> {
  SperatedType selectedRunnerSource = SperatedType.newOne;
  int _selectedCameraCount = 5;
  int _index = 0;
  List<int> unuploadedCameraIndexes = [0, 1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final runnerId = ref.watch(uploadSelectedRunnerIdProvider);
    final selectedVideoId = ref.watch(uploadSelectedRunSessionIdProvider);
    final formData = ref.watch(uploadSeperatelyFormProvider);
    final formNotifier = ref.read(uploadSeperatelyFormProvider.notifier);

    if (runnerId == null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          l10n.pleaseSelectRunnerFirst,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    final runnerUnanalyzedVideos = ref.watch(
      runnerUnanalyzedHistoryProvider(runnerId),
    );
    final state = ref.watch(uploadSeperatelyControllerProvider);
    final controller = ref.read(uploadSeperatelyControllerProvider.notifier);
    return Column(
      spacing: 16,
      children: [
        CustomSlidingSegmentedControl<SperatedType>(
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
            setState(() {
              selectedRunnerSource = value;
              // 切換模式時重置上傳狀態（包含縮圖）
              ref
                  .read(uploadSeperatelyControllerProvider.notifier)
                  .resetState();

              if (value == SperatedType.newOne) {
                unuploadedCameraIndexes = [0, 1, 2, 3, 4];
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
            selectedDate: formData.selectedDate,
            selectedTime: formData.selectedTime,
            selectedCameraCount: _selectedCameraCount,
            selectedFps: formData.fps,
            note: formData.note,
            isLongJump: formData.isLongJump,
            onDateSelected: (date) {
              formNotifier.state = formData.copyWith(selectedDate: date);
            },
            onTimeSelected: (time) {
              formNotifier.state = formData.copyWith(selectedTime: time);
            },
            onCameraCountSelected: (cameraCount) {
              setState(() {
                _selectedCameraCount = cameraCount;
              });
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
          ),
        if (selectedRunnerSource == SperatedType.selectOne)
          AsyncValueWidget(
            value: runnerUnanalyzedVideos,
            data: (List<UnanalyzedRunSessionInfo> value) {
              return Column(
                spacing: 16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      l10n.pleaseSelectRecordToUpload,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  UnanalyzedHistoryView(
                    onVideoSelected: (video) {
                      setState(() {
                        unuploadedCameraIndexes = video.unuploadedCameraIndexes;
                        if (unuploadedCameraIndexes.isNotEmpty) {
                          _index = unuploadedCameraIndexes.first;
                        }
                      });
                    },
                  ),
                ],
              );
            },
          ),
        if (selectedVideoId != null ||
            selectedRunnerSource == SperatedType.newOne)
          Row(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  l10n.cameraIndexNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2<int>(
                  hint: Row(
                    children: [
                      Text(
                        l10n.cameraCount,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  items: unuploadedCameraIndexes
                      .map(
                        (item) => DropdownMenuItem<int>(
                          value: item,
                          child: Text(
                            '${l10n.camera} ${item + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  value: _index,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _index = value;
                      });
                    }
                  },
                  buttonStyleData: ButtonStyleData(
                    width: 120,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_forward_ios_outlined),
                    iconSize: 12,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    scrollbarTheme: const ScrollbarThemeData(
                      radius: Radius.circular(40),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 12, right: 12),
                  ),
                ),
              ),
            ],
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
              children: [
                GestureDetector(
                  onTap: state.isUploading
                      ? null // 上傳中不能再點
                      : () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.video,
                            withData: true,
                          );

                          if (result == null) return;

                          final file = result.files.first;

                          final uploadFile = UploadVideoFile(
                            bytes: file.bytes!,
                            filename: file.name,
                            mimeType: lookupMimeType(file.name) ?? 'video/mp4',
                          );

                          await controller.uploadVideo(_index, uploadFile);

                          if (!context.mounted) return;

                          // After upload, prompt anchor selection
                          final updatedState = ref.read(
                            uploadSeperatelyControllerProvider,
                          );
                          final thumbnailUrl = updatedState.thumbnail;
                          if (thumbnailUrl != null) {
                            final anchor = await showAnchorPointDialog(
                              context: context,
                              thumbnailUrl: thumbnailUrl,
                              cameraIndex: _index,
                              initialAnchor: ref
                                  .read(uploadSeperatelyControllerProvider)
                                  .anchorResult,
                            );
                            if (!context.mounted) return;
                            ref
                                .read(
                                  uploadSeperatelyControllerProvider.notifier,
                                )
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
                                    child: Image.network(
                                      state.thumbnail!,
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
                                      final anchor =
                                          await showAnchorPointDialog(
                                            context: context,
                                            thumbnailUrl: state.thumbnail!,
                                            cameraIndex: _index,
                                            initialAnchor: state.anchorResult,
                                          );
                                      if (!context.mounted) return;
                                      ref
                                          .read(
                                            uploadSeperatelyControllerProvider
                                                .notifier,
                                          )
                                          .setAnchor(anchor);
                                    },
                                    child: _AnchorBadge(
                                      isSet: state.anchorResult != null,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Text(
                                '${l10n.camera} ${_index + 1}\n${l10n.clickToUpload}',
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
                    runnerId,
                    formData.selectedDate,
                    formData.selectedTime,
                    _selectedCameraCount,
                    formData.fps,
                    formData.note,
                    formData.isLongJump,
                    _index,
                    state.tempVideoId!,
                    state.anchorResult,
                  );
            }
            if (selectedRunnerSource == SperatedType.selectOne) {
              status = await ref
                  .read(uploadControllerProvider.notifier)
                  .uploadSeperatelySelect(
                    runnerId,
                    selectedVideoId!,
                    _index,
                    state.tempVideoId!,
                    state.anchorResult,
                  );
            }
            if (status == null || !context.mounted) return;
            final uploadStatus = status;

            // 無論是否上傳完成，都更新未分析紀錄列表，確保「選擇紀錄」能看到最新狀態
            ref.invalidate(runnerUnanalyzedHistoryProvider(runnerId));

            if (uploadStatus.isAllUploaded == true) {
              // Invalidate history to ensure we fetch the latest list
              ref.invalidate(runnerHistoryProvider(runnerId));
              context.goNamed(
                AppRoute.playback.name,
                queryParameters: {
                  'runnerId': runnerId,
                  'videoId': uploadStatus.runSessionId,
                },
              );
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Notice'),
                    content: Text(
                      '${l10n.pleaseUploadAllVideos}: ${uploadStatus.unuploadedCameraIndexes.map((e) => "${l10n.camera} ${e + 1}").join(', ')}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // 上傳部分成功後，重置縮圖以便上傳下一個
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
