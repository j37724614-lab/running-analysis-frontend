import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/feature/guide/guide_steps_factory.dart';
import 'package:frontend/feature/guide/guide_tour_service.dart';
import 'package:frontend/feature/record/record_controller.dart';
import 'package:frontend/feature/record/record_enums.dart';
import 'package:frontend/feature/record/record_state.dart';
import 'package:frontend/feature/record/widget/record_camera_view.dart';
import 'package:frontend/feature/record/widget/record_tour_placeholder_view.dart';
import 'package:frontend/feature/upload/upload_controller.dart';
import 'package:frontend/feature/upload/widget/upload_enums.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/widget/rounded_box_widget.dart';
import 'package:frontend/entities/runner_info.dart';
import 'package:frontend/feature/record/widget/record_room_share_dialog.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

class RecordPage extends ConsumerStatefulWidget {
  final String? initialRoomId;
  final int? initialCameraIndex;

  const RecordPage({super.key, this.initialRoomId, this.initialCameraIndex});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
  final TextEditingController _roomController = TextEditingController();
  int _selectedCameraIndex = 0;
  int _createExpectedCount = 1;
  String _newRunnerName = '';
  final ExpansibleController _expansionController = ExpansibleController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCameraIndex != null) {
      _selectedCameraIndex = widget.initialCameraIndex!;
    }
    if (widget.initialRoomId != null && widget.initialRoomId!.isNotEmpty) {
      _roomController.text = widget.initialRoomId!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final currentState = ref.read(recordControllerProvider);
        if (currentState.status == RecordStatus.idle ||
            currentState.roomId != widget.initialRoomId) {
          final cameraIdx = widget.initialCameraIndex ?? _selectedCameraIndex;
          ref.read(recordControllerProvider.notifier).joinRoom(widget.initialRoomId!, cameraIdx);
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          if (widget.initialRoomId == null || widget.initialRoomId!.isEmpty) {
            GuideTourService.startRecordTour(context: context, ref: ref, force: false);
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant RecordPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCameraIndex != null &&
        widget.initialCameraIndex != oldWidget.initialCameraIndex) {
      _selectedCameraIndex = widget.initialCameraIndex!;
    }
    if (widget.initialRoomId != null &&
        widget.initialRoomId!.isNotEmpty &&
        widget.initialRoomId != oldWidget.initialRoomId) {
      _roomController.text = widget.initialRoomId!;
      final currentState = ref.read(recordControllerProvider);
      if (currentState.status == RecordStatus.idle || currentState.roomId != widget.initialRoomId) {
        final cameraIdx = widget.initialCameraIndex ?? _selectedCameraIndex;
        ref.read(recordControllerProvider.notifier).joinRoom(widget.initialRoomId!, cameraIdx);
      }
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(recordControllerProvider);
    final controller = ref.read(recordControllerProvider.notifier);
    final isDemoInRoom = ref.watch(recordTourDemoInRoomProvider);
    final demoRole = ref.watch(recordTourDemoRoleProvider);
    final inRealRoom = state.status != RecordStatus.idle && state.status != RecordStatus.connecting;

    final displayState = (isDemoInRoom && !inRealRoom)
        ? RecordState(
            role: demoRole,
            status: RecordStatus.ready,
            roomId: '8888',
            expectedCameraCount: 2,
            isRecordingEnabled: demoRole == RecordRole.master,
            myCameraIndex: demoRole == RecordRole.master ? 0 : 1,
            runnerSource: RunnerSource.select,
            fps: 60,
            note: '100m 衝刺同步錄影',
            members: [
              RecordMember(id: 'Master-01', isMaster: true, cameraIndex: 0, isReady: true),
              RecordMember(id: 'Slave-02', isMaster: false, cameraIndex: 1, isReady: true),
            ],
          )
        : state;

    // 監聽狀態變化來觸發動畫，而不使用會破壞動畫的 Key
    ref.listen(recordControllerProvider.select((s) => s.isRecordingEnabled), (prev, next) {
      if (next) {
        _expansionController.expand();
      } else {
        _expansionController.collapse();
      }
    });

    ref.listen(recordControllerProvider.select((s) => s.isAllUploaded), (prev, next) {
      if (next == true && prev != true) {
        toastification.show(
          context: context,
          title: const Text('Success', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text(l10n.uploadSuccess),
          type: ToastificationType.success,
          style: ToastificationStyle.minimal,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    });

    ref.listen(recordControllerProvider.select((s) => s.error), (prev, next) {
      if (next != null && next != prev) {
        toastification.show(
          context: context,
          title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text(next),
          type: ToastificationType.error,
          style: ToastificationStyle.minimal,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    });

    ref.listen(recordControllerProvider.select((s) => s.pendingControlRequestFrom), (prev, next) {
      if (next != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(l10n.controlTransferRequest),
            content: Text(l10n.controlTransferMessage(next)),
            actions: [
              TextButton(
                onPressed: () {
                  controller.respondControlRequest(next, false);
                  Navigator.of(context).pop();
                },
                child: Text(l10n.reject),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.respondControlRequest(next, true);
                  Navigator.of(context).pop();
                },
                child: Text(l10n.approve),
              ),
            ],
          ),
        );
      }
    });

    // 同步本機物理轉向狀態到控制器
    final orientation = MediaQuery.of(context).orientation;
    final isPhysicallyReady = orientation != Orientation.portrait;

    // 使用 microtask 避免在 build 期間直接呼叫 state 更新
    Future.microtask(() {
      if (mounted) {
        controller.updatePhysicallyReady(isPhysicallyReady);
      }
    });

    final body =
        displayState.status == RecordStatus.idle || displayState.status == RecordStatus.connecting
        ? _buildInitialView(displayState, controller)
        : _buildRoomView(displayState, controller, isTourDemo: isDemoInRoom && !inRealRoom);

    return body;
  }

  Widget _buildInitialView(RecordState state, RecordController controller) {
    final l10n = context.l10n;
    if (state.status == RecordStatus.connecting) {
      final hasRoomId = state.roomId != null && state.roomId!.isNotEmpty;
      final loadingText = hasRoomId
          ? '${l10n.statusProcessing}... (${l10n.roomNumber}: ${state.roomId})'
          : '${l10n.statusProcessing}...';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitCubeGrid(color: Theme.of(context).primaryColor, size: 50.0),
            const SizedBox(height: 20),
            Text(loadingText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: MaxWidth(
                  maxWidth: 400,
                  child: Column(
                    spacing: 24,
                    children: [
                      Container(
                        key: GuideKeys.recordRoleMasterKey,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(width: 3, color: Theme.of(context).primaryColor),
                        ),
                        child: Column(
                          spacing: 12,
                          children: [
                            Icon(Icons.stars, size: 48, color: Theme.of(context).primaryColorDark),
                            Text(
                              l10n.masterDevice,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(l10n.masterDeviceDescription, textAlign: TextAlign.center),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(l10n.expectedDeviceCount),
                                DropdownButton2<int>(
                                  value: _createExpectedCount,
                                  items: [1, 2, 3, 4, 5]
                                      .map(
                                        (e) =>
                                            DropdownMenuItem(value: e, child: Text(e.toString())),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(() => _createExpectedCount = v!),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(Icons.arrow_forward_ios_outlined),
                                    iconSize: 12,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(40),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              onPressed: () => controller.createRoom(_createExpectedCount),
                              child: Text(
                                l10n.createRecordingRoom,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(l10n.orDivider, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        key: GuideKeys.recordRoleSlaveKey,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(width: 3, color: Theme.of(context).primaryColor),
                        ),
                        child: Column(
                          spacing: 12,
                          children: [
                            Icon(
                              Icons.phonelink,
                              size: 48,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            Text(
                              l10n.slaveDevice,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (_roomController.text.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 14,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${l10n.autoFilledRoomNumber}: ${_roomController.text}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            TextField(
                              controller: _roomController,
                              decoration: InputDecoration(
                                hintText: l10n.enterRoomNumber,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.meeting_room),
                              ),
                            ),
                            DropdownButtonFormField<int>(
                              value: _selectedCameraIndex,
                              decoration: InputDecoration(
                                labelText: l10n.selectCameraPosition,
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.camera_alt),
                              ),
                              items: List.generate(
                                5,
                                (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text('${l10n.camera} ${i + 1}'),
                                ),
                              ),
                              onChanged: (v) => setState(() => _selectedCameraIndex = v!),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Theme.of(context).primaryColor,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              onPressed: () {
                                if (_roomController.text.isNotEmpty) {
                                  controller.joinRoom(_roomController.text, _selectedCameraIndex);
                                }
                              },
                              child: Text(
                                l10n.joinRecordingRoom,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomView(RecordState state, RecordController controller, {bool isTourDemo = false}) {
    final l10n = context.l10n;
    final connectedCameraIndexes = state.members.map((m) => m.cameraIndex).whereType<int>().toSet();
    final areAllCamerasConnected =
        state.expectedCameraCount > 0 &&
        List.generate(
          state.expectedCameraCount,
          (i) => i,
        ).every((i) => connectedCameraIndexes.contains(i));

    final participatingMembers = state.members.where((m) => m.cameraIndex != null);
    final areAllParticipatingReady = participatingMembers.every((m) => m.isReady);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: MaxWidth(
                  maxWidth: 600,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 24,
                    children: [
                      Column(
                        key: GuideKeys.recordRoomInfoKey,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${l10n.roomNumber}: ${state.roomId}',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: state.role == RecordRole.master
                                      ? Colors.amber[100]
                                      : Colors.blue[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${l10n.currentRole}: ${state.role == RecordRole.master ? l10n.roleMaster : l10n.roleSlave}',
                                  style: TextStyle(
                                    color: state.role == RecordRole.master
                                        ? Colors.amber[900]
                                        : Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (state.role == RecordRole.master && state.roomId != null) ...[
                                KeyedSubtree(
                                  key: GuideKeys.recordRoomShareKey,
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                RecordRoomShareDialog(roomId: state.roomId!),
                                          );
                                        },
                                        icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                                        label: Text(l10n.shareRoom),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).primaryColor,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          final url = getRoomJoinUrl(state.roomId!);
                                          Clipboard.setData(ClipboardData(text: url));
                                          toastification.show(
                                            context: context,
                                            title: Text(l10n.joinLinkCopied),
                                            type: ToastificationType.success,
                                            style: ToastificationStyle.minimal,
                                            alignment: Alignment.bottomCenter,
                                            autoCloseDuration: const Duration(seconds: 3),
                                          );
                                        },
                                        icon: const Icon(Icons.copy_rounded, size: 16),
                                        label: Text(l10n.copyLink),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Theme.of(context).primaryColorDark,
                                          side: BorderSide(color: Theme.of(context).primaryColor),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      if (state.role == RecordRole.master &&
                          state.status != RecordStatus.recording &&
                          state.status != RecordStatus.uploading) ...[
                        KeyedSubtree(
                          key: GuideKeys.recordConfigKey,
                          child: _buildConfigSection(state, controller),
                        ),
                        Container(
                          key: GuideKeys.recordLocalRecordKey,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(width: 3, color: Theme.of(context).primaryColor),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              controller: _expansionController,
                              maintainState: true,
                              initiallyExpanded: state.isRecordingEnabled,
                              onExpansionChanged: (expanded) {
                                if (expanded != state.isRecordingEnabled) {
                                  if (expanded) {
                                    controller.toggleMasterRecording(true, 0);
                                  } else {
                                    controller.toggleMasterRecording(false);
                                  }
                                }
                              },
                              title: Text(
                                l10n.localRecording,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: state.isRecordingEnabled
                                  ? Text('${l10n.camera} ${state.myCameraIndex! + 1}')
                                  : Text(l10n.roleMaster),
                              trailing: Switch(
                                value: state.isRecordingEnabled,
                                onChanged: (v) {
                                  if (v) {
                                    controller.toggleMasterRecording(true, 0);
                                  } else {
                                    controller.toggleMasterRecording(false);
                                  }
                                },
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.selectCameraPosition,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          spacing: 8,
                                          children: List.generate(state.expectedCameraCount, (i) {
                                            return ChoiceChip(
                                              label: Text('${l10n.camera} ${i + 1}'),
                                              selected: state.myCameraIndex == i,
                                              onSelected: (selected) {
                                                if (selected) {
                                                  controller.toggleMasterRecording(true, i);
                                                }
                                              },
                                            );
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (state.role == RecordRole.slave &&
                          state.status != RecordStatus.recording &&
                          state.status != RecordStatus.uploading) ...[
                        Column(
                          key: GuideKeys.recordSlaveCameraPosKey,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.changeCameraPosition,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value:
                                  (state.myCameraIndex != null &&
                                      state.myCameraIndex! <
                                          (state.expectedCameraCount > 0
                                              ? state.expectedCameraCount
                                              : 5))
                                  ? state.myCameraIndex
                                  : null,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.camera_alt),
                              ),
                              items: List.generate(
                                state.expectedCameraCount > 0 ? state.expectedCameraCount : 5,
                                (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text('${l10n.camera} ${i + 1}'),
                                ),
                              ).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  controller.joinRoom(state.roomId!, v);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                      Text(
                        l10n.connectedDevices,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      RoundedBoxWidget(
                        key: GuideKeys.recordDevicesKey,
                        child: state.members.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(l10n.waitingForConnection),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.members.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final member = state.members[index];
                                  return ListTile(
                                    leading: CircleAvatar(child: Text('${index + 1}')),
                                    title: Row(
                                      children: [
                                        Text('ID: ${member.id}'),
                                        if (member.isMaster) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber[100],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              l10n.roomHost,
                                              style: TextStyle(
                                                color: Colors.amber[900],
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    subtitle: Text(
                                      member.cameraIndex != null
                                          ? '${l10n.camera} ${member.cameraIndex! + 1}'
                                          : l10n.cameraNotAssigned,
                                    ),
                                    trailing: Icon(
                                      member.isReady ? Icons.check_circle : Icons.error,
                                      color: member.isReady ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (state.role == RecordRole.master) ...[
                        if (state.status == RecordStatus.recording) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SpinKitDoubleBounce(color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.recordingInProgress,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            key: GuideKeys.recordButtonKey,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () => controller.stopRecording(),
                            child: Text(
                              l10n.stopRecordingAndUpload,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ] else if (state.status == RecordStatus.uploading) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SpinKitDoubleBounce(color: Color(0xFF79A9EA), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.autoUploading,
                                style: const TextStyle(
                                  color: Color(0xFF2A3E5C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(l10n.autoUploading, style: const TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                        ] else ...[
                          ElevatedButton(
                            key: GuideKeys.recordButtonKey,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              if (state.runnerId == null) {
                                toastification.show(
                                  context: context,
                                  title: const Text(
                                    'Error',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  description: Text(l10n.selectRunnerRequired),
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.minimal,
                                  alignment: Alignment.bottomCenter,
                                  autoCloseDuration: const Duration(seconds: 4),
                                );
                                return;
                              }
                              if (!areAllCamerasConnected) {
                                toastification.show(
                                  context: context,
                                  title: const Text(
                                    'Error',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  description: Text(
                                    '${l10n.cameraNotAssigned} (${connectedCameraIndexes.length}/${state.expectedCameraCount})',
                                  ),
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.minimal,
                                  alignment: Alignment.bottomCenter,
                                  autoCloseDuration: const Duration(seconds: 4),
                                );
                                return;
                              }

                              if (!areAllParticipatingReady) {
                                toastification.show(
                                  context: context,
                                  title: const Text(
                                    'Warning',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  description: Text(l10n.orientationLandscapeRequired),
                                  alignment: Alignment.bottomCenter,
                                  type: ToastificationType.warning,
                                  style: ToastificationStyle.minimal,
                                  autoCloseDuration: const Duration(seconds: 4),
                                );
                                return;
                              }
                              controller.startRecording();
                            },
                            child: Text(
                              l10n.startSyncRecording,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ],
                      if (state.role == RecordRole.slave ||
                          state.isRecordingEnabled ||
                          isTourDemo) ...[
                        KeyedSubtree(
                          key: GuideKeys.recordCameraKey,
                          child: isTourDemo
                              ? const RecordTourCameraPlaceholderView()
                              : const RecordCameraView(),
                        ),
                      ],
                      if (state.role == RecordRole.slave) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          key: GuideKeys.recordRequestControlKey,
                          icon: state.isWaitingForControlApproval
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black54,
                                  ),
                                )
                              : const Icon(Icons.swap_horizontal_circle_outlined, size: 16),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(200, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: state.isWaitingForControlApproval
                              ? null
                              : () => controller.requestControl(),
                          label: Text(
                            state.isWaitingForControlApproval
                                ? l10n.waitingForControlApproval
                                : (state.members.any((m) => m.isMaster)
                                      ? l10n.requestControl
                                      : l10n.takeControl),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      TextButton.icon(
                        key: GuideKeys.recordLeaveRoomKey,
                        icon: const Icon(Icons.exit_to_app),
                        onPressed: () => controller.leaveRoom(),
                        label: Text(l10n.leaveRoom),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfigSection(RecordState state, RecordController controller) {
    final l10n = context.l10n;
    final runners = ref.watch(uploadRunnerListProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 3, color: Theme.of(context).primaryColor),
      ),
      child: Column(
        spacing: 16,
        children: [
          Text(
            l10n.cameraSettings,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CustomSlidingSegmentedControl<RunnerSource>(
                initialValue: state.runnerSource,
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
                  if (value != null) controller.setRunnerSource(value);
                },
                children: {
                  RunnerSource.select: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.selectRunner,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: state.runnerSource == RunnerSource.select
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
                        fontWeight: state.runnerSource == RunnerSource.add
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                },
              ),
              if (state.runnerSource == RunnerSource.select)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
                  child: AsyncValueWidget(
                    value: runners,
                    loading: Shimmer.fromColors(
                      baseColor: Theme.of(context).primaryColorDark,
                      highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      child: Container(
                        height: 40,
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.selectRunner,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.arrow_forward_ios_outlined, size: 12),
                          ],
                        ),
                      ),
                    ),
                    data: (List<RunnerInfo> items) => DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        hint: Row(
                          children: [
                            Text(
                              l10n.selectRunner,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        value: state.runnerId,
                        onChanged: (v) => controller.setRunner(v),
                        buttonStyleData: ButtonStyleData(
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
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                          scrollbarTheme: const ScrollbarThemeData(radius: Radius.circular(40)),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.only(left: 12, right: 12),
                        ),
                      ),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
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
                          onChanged: (v) => setState(() => _newRunnerName = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {
                          if (_newRunnerName.isNotEmpty) {
                            await controller.addRunner(_newRunnerName);
                            setState(() {
                              _newRunnerName = '';
                            });
                          }
                        },
                        label: Text(
                          l10n.save,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        icon: const Icon(Icons.add_circle_rounded, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Row(
            spacing: 16,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  l10n.fps,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2<int>(
                  hint: Text(
                    l10n.fps,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  value: state.fps,
                  items: [30, 60]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.toString(),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => v != null ? controller.setFps(v) : null,
                  buttonStyleData: ButtonStyleData(
                    width: 100,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor)),
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_forward_ios_outlined),
                    iconSize: 12,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 12, right: 12),
                  ),
                ),
              ),
            ],
          ),
          Row(
            spacing: 16,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  l10n.notes,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: TextField(
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l10n.notes,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (v) => controller.setNote(v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MaxWidth extends StatelessWidget {
  final double maxWidth;
  final Widget child;
  const MaxWidth({super.key, required this.maxWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
  }
}
