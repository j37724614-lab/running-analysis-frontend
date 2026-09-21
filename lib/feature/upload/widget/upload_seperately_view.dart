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
    final selectedRunnerSource = ref.watch(uploadSeparatelyTypeProvider);
    final formData = ref.watch(uploadSeperatelyFormProvider);
    final formNotifier = ref.read(uploadSeperatelyFormProvider.notifier);
    final state = ref.watch(uploadSeperatelyControllerProvider);
    final controller = ref.read(uploadSeperatelyControllerProvider.notifier);

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
            child: runnerId == null
                ? const _UnanalyzedHistoryPlaceholder()
                : UnanalyzedHistoryView(
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
        if (selectedVideoId != null ||
            selectedRunnerSource == SperatedType.newOne ||
            runnerId == null)
          Row(
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
                  items: unuploadedCameraIndexes
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
                  value: _index,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _index = value;
                      });
                    }
                  },
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

        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = (width > 600 ? 500.0 : width).clamp(240.0, 500.0);
            final itemHeight = itemWidth * 9 / 16;
            final spacing = 12.0;

            return Wrap(
              key: GuideKeys.uploadSepVideoKey,
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: [
                GestureDetector(
                  onTap: state.isUploading
                      ? null // 上傳中不能再點
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

                          await controller.uploadVideo(_index, uploadFile);

                          // After upload, prompt anchor selection
                          final updatedState = ref.read(uploadSeperatelyControllerProvider);
                          final thumbnailUrl = updatedState.thumbnail;
                          if (mounted && thumbnailUrl != null) {
                            final anchor = await showAnchorPointDialog(
                              context: context,
                              thumbnailUrl: thumbnailUrl,
                              cameraIndex: _index,
                              initialAnchor: ref
                                  .read(uploadSeperatelyControllerProvider)
                                  .anchorResult,
                            );
                            ref.read(uploadSeperatelyControllerProvider.notifier).setAnchor(anchor);
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
                                        cameraIndex: _index,
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
                                '${l10n.camera} ${_index + 1}\n${l10n.clickToUpload}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          key: GuideKeys.uploadSepSubmitKey,
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
                    _index,
                    state.tempVideoId!,
                    state.anchorResult,
                  );
            }
            if (selectedRunnerSource == SperatedType.selectOne) {
              if (selectedVideoId == null) return;
              status = await ref
                  .read(uploadControllerProvider.notifier)
                  .uploadSeperatelySelect(
                    runnerId,
                    selectedVideoId,
                    _index,
                    state.tempVideoId!,
                    state.anchorResult,
                  );
            }
            if (mounted && status != null) {
              // 無論是否上傳完成，都更新未分析紀錄列表，確保「選擇紀錄」能看到最新狀態
              ref.invalidate(runnerUnanalyzedHistoryProvider(runnerId));

              if (status.isAllUploaded == true) {
                // Invalidate history to ensure we fetch the latest list
                ref.invalidate(runnerHistoryProvider(runnerId));

                if (mounted) {
                  context.goNamed(
                    AppRoute.playback.name,
                    queryParameters: {'runnerId': runnerId, 'videoId': status.runSessionId},
                  );
                }
              } else {
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
                            // 上傳部分成功後，重置縮圖以便上傳下一個
                            ref.read(uploadSeperatelyControllerProvider.notifier).resetState();
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

/// Realistic unanalyzed history placeholder shown when no runner is currently selected
class _UnanalyzedHistoryPlaceholder extends StatelessWidget {
  const _UnanalyzedHistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sampleItems = [
      (
        date: "2026-09-02 10:30",
        cameraCount: 3,
        missing: "2, 3",
        note: "100m 衝刺測驗",
        isSelected: true,
      ),
      (
        date: "2026-09-01 16:15",
        cameraCount: 5,
        missing: "4, 5",
        note: "起跑出發練習",
        isSelected: false,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 600 ? constraints.maxWidth : 500.0;
        return Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  children: [
                    Icon(
                      Icons.pending_actions_rounded,
                      size: 16,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        l10n.uncompletedRecordsPlaceholder,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: sampleItems.length,
                  itemBuilder: (context, index) {
                    final item = sampleItems[index];
                    final isSelected = item.isSelected;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColorDark : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColorDark
                                : Theme.of(context).primaryColor.withValues(alpha: 0.35),
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_run,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).primaryColorDark,
                                size: 17,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 2,
                                    children: [
                                      Text(
                                        item.date,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isSelected ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.videocam_outlined,
                                            size: 13,
                                            color: isSelected
                                                ? Colors.white.withValues(alpha: 0.8)
                                                : Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            "${item.cameraCount} ${l10n.cameras}",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isSelected
                                                  ? Colors.white.withValues(alpha: 0.8)
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withValues(alpha: 0.2)
                                              : Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.white30
                                                : Colors.orange.shade200,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          "缺相機 ${item.missing}",
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.orange.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.note.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.note,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontStyle: FontStyle.italic,
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.7)
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                "待補傳",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.amber.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
