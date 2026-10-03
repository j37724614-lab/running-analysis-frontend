import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/feature/guide/guide_steps_factory.dart';
import 'package:frontend/feature/guide/guide_tour_service.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/runner_info.dart';
import 'package:frontend/feature/upload/upload_controller.dart';
import 'package:frontend/feature/upload/upload_provider.dart';
import 'package:frontend/feature/upload/widget/anchor_point_tour_placeholder_dialog.dart';
import 'package:frontend/feature/upload/widget/upload_all_view.dart';
import 'package:frontend/feature/upload/widget/upload_seperately_view.dart';
import 'package:frontend/feature/upload/widget/upload_seperately_controller.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/widget/async_value_ui.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/widget/loading_overlay.dart';
import 'package:frontend/feature/upload/widget/upload_enums.dart';
import 'package:frontend/feature/upload/widget/upload_form_provider.dart';
import 'package:shimmer/shimmer.dart';

class UploadPage extends ConsumerStatefulWidget {
  final String? runSessionId;
  const UploadPage({super.key, this.runSessionId});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  @override
  void initState() {
    super.initState();
    if (widget.runSessionId != null && widget.runSessionId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        ref.read(uploadTypeProvider.notifier).state = UploadType.seperated;
        ref.read(uploadSeparatelyTypeProvider.notifier).state = SperatedType.selectOne;
        try {
          final session = await ref
              .read(backendProvider)
              .getUnanalyzedRunSessionById(widget.runSessionId!);
          if (session != null && mounted) {
            var runners = ref.read(uploadRunnerListProvider).value;
            if (runners == null) {
              try {
                runners = await ref.read(backendProvider).getRunners();
              } catch (_) {
                runners = [];
              }
            }
            final isOwnRunner = runners.any((r) => r.id == session.runnerId);
            if (isOwnRunner) {
              ref.read(uploadExternalSessionInfoProvider.notifier).state = null;
              ref.read(uploadSelectedRunnerIdProvider.notifier).state = session.runnerId;
              ref.read(uploadSelectedRunSessionIdProvider.notifier).state = session.runSessionId;
            } else {
              ref.read(uploadExternalSessionInfoProvider.notifier).state = session;
              ref.read(uploadSelectedRunnerIdProvider.notifier).state = null;
              ref.read(uploadSelectedRunSessionIdProvider.notifier).state = session.runSessionId;
            }
          }
        } catch (_) {}
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          GuideTourService.startTour(
            context: context,
            tourKey: GuideTourService.tourUpload,
            steps: GuideStepsFactory.getUploadSteps(context, ref),
            onFinish: () {
              ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            },
            onSkip: () {
              ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
            },
            force: false,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedUploadType = ref.watch(uploadTypeProvider);
    final selectedRunnerSource = ref.watch(runnerSourceProvider);
    final name = ref.watch(runnerNameInputProvider);

    final typeNotifier = ref.read(uploadTypeProvider.notifier);
    final sourceNotifier = ref.read(runnerSourceProvider.notifier);
    final nameNotifier = ref.read(runnerNameInputProvider.notifier);

    ref.listen<AsyncValue>(
      uploadControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(uploadControllerProvider);
    final runners = ref.watch(uploadRunnerListProvider);
    final selectedRunnerId = ref.watch(uploadSelectedRunnerIdProvider);

    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomPadding = isPortrait ? (90.0 + bottomInset) : 24.0;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPadding),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    key: GuideKeys.uploadRunnerKey,
                    alignment: WrapAlignment.center,
                    runSpacing: 16,
                    spacing: 16,
                    children: [
                      CustomSlidingSegmentedControl<RunnerSource>(
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
                        onValueChanged: (RunnerSource? value) {
                          if (value == null) return;
                          sourceNotifier.state = value;
                        },
                        children: <RunnerSource, Widget>{
                          RunnerSource.select: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              l10n.selectRunner,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: selectedRunnerSource == RunnerSource.select
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          RunnerSource.add: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              l10n.addRunner,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: selectedRunnerSource == RunnerSource.add
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        },
                      ),
                      if (selectedRunnerSource == RunnerSource.select)
                        AsyncValueWidget(
                          value: runners,
                          loading: Shimmer.fromColors(
                            baseColor: Theme.of(context).primaryColorDark,
                            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                            child: Container(
                              width: 100,
                              height: 40,
                              decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.selectRunner,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_outlined, size: 12),
                                ],
                              ),
                            ),
                          ),
                          data: (List<RunnerInfo> items) {
                            final isSelectedRunnerValid =
                                selectedRunnerId != null &&
                                items.any((r) => r.id == selectedRunnerId);
                            if (!isSelectedRunnerValid && selectedRunnerId != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted &&
                                    ref.read(uploadExternalSessionInfoProvider) == null) {
                                  ref.read(uploadSelectedRunnerIdProvider.notifier).state = null;
                                }
                              });
                            }
                            final effectiveSelectedRunnerId = isSelectedRunnerValid
                                ? selectedRunnerId
                                : null;

                            return DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                hint: Row(
                                  children: [
                                    Text(
                                      l10n.selectRunner,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                items: items
                                    .map(
                                      (RunnerInfo item) => DropdownMenuItem<String>(
                                        value: item.id,
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                value: effectiveSelectedRunnerId,
                                onChanged: (value) {
                                  if (value != selectedRunnerId) {
                                    ref.read(uploadSelectedRunnerIdProvider.notifier).state = value;
                                    ref.read(uploadSelectedRunSessionIdProvider.notifier).state =
                                        null;
                                    ref
                                        .read(uploadSeperatelyControllerProvider.notifier)
                                        .resetState();
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  width: 100,
                                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Theme.of(context).primaryColor),
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
                            );
                          },
                        ),
                    ],
                  ),
                  if (selectedRunnerSource == RunnerSource.add)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextField(
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: l10n.enterRunnerName,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onChanged: (value) {
                                nameNotifier.state = value;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: () async {
                              final newRunner = await ref
                                  .read(uploadRunnerListProvider.notifier)
                                  .addRunner(name);

                              sourceNotifier.state = RunnerSource.select;
                              ref.read(uploadSelectedRunnerIdProvider.notifier).state =
                                  newRunner.id;
                            },
                            label: Text(
                              l10n.save,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(
                              Icons.add_circle_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (selectedRunnerSource != RunnerSource.add)
                    CustomSlidingSegmentedControl<UploadType>(
                      key: GuideKeys.uploadTabsKey,
                      customSegmentSettings: CustomSegmentSettings(
                        borderRadius: const BorderRadius.all(Radius.circular(25)),
                      ),
                      initialValue: selectedUploadType,
                      onValueChanged: (UploadType? value) {
                        if (value == null) return;
                        typeNotifier.state = value;
                      },
                      decoration: BoxDecoration(
                        color: CupertinoColors.tertiarySystemFill,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      thumbDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      children: <UploadType, Widget>{
                        UploadType.all: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.uploadAll,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: selectedUploadType == UploadType.all
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        UploadType.seperated: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.uploadSeparately,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: selectedUploadType == UploadType.seperated
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      },
                    ),
                  if (selectedRunnerSource != RunnerSource.add)
                    selectedUploadType == UploadType.all
                        ? const UploadAllView()
                        : const UploadSeperatelyView(),
                ],
              ),
            ),
          ),
        ),
        if (state.isLoading) const LoadingOverlay(),
        if (ref.watch(uploadTourAnchorPlaceholderOpenProvider))
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: AnchorPointTourPlaceholderDialog(
                key: GuideKeys.uploadAnchorKey,
                onClose: () {
                  ref.read(uploadTourAnchorPlaceholderOpenProvider.notifier).state = false;
                },
              ),
            ),
          ),
      ],
    );
  }
}
