import 'package:frontend/feature/record/record_enums.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';
import 'package:frontend/feature/upload/widget/upload_enums.dart';

class RecordState {
  final RecordRole role;
  final RecordStatus status;
  final String? roomId;
  final List<RecordMember> members;
  final String? error;
  final int? myDeviceInfoIndex; // For Slave to know which camera it is
  final int? myCameraIndex; // Assigned camera index (0-4)
  final String? sharedRunSessionId; // Synced after first upload
  final int expectedCameraCount;
  final bool isRecordingEnabled; // For Master
  final bool isPhysicallyReady; // Track local physical orientation (landscape)

  // Upload Parameters
  final RunnerSource runnerSource;
  final String? runnerId;
  final String? runnerName; // For "Add New Runner" case
  final int fps;
  final String note;
  final bool isLongJump;

  // Calibration
  final AnchorResult? anchorResult;

  // Upload Progress
  final bool isAllUploaded;

  // Room Control Request
  final String? pendingControlRequestFrom;
  final bool isWaitingForControlApproval;

  RecordState({
    this.role = RecordRole.none,
    this.status = RecordStatus.idle,
    this.roomId,
    this.members = const [],
    this.error,
    this.myDeviceInfoIndex,
    this.myCameraIndex,
    this.sharedRunSessionId,
    this.expectedCameraCount = 0,
    this.isRecordingEnabled = false,
    this.isPhysicallyReady = false,
    this.runnerSource = RunnerSource.select,
    this.runnerId,
    this.runnerName,
    this.fps = 60,
    this.note = '',
    this.isLongJump = false,
    this.anchorResult,
    this.isAllUploaded = false,
    this.pendingControlRequestFrom,
    this.isWaitingForControlApproval = false,
  });

  bool get anchorIsSet => anchorResult != null;

  RecordState copyWith({
    RecordRole? role,
    RecordStatus? status,
    String? roomId,
    List<RecordMember>? members,
    String? error,
    int? myDeviceInfoIndex,
    int? myCameraIndex,
    String? sharedRunSessionId,
    int? expectedCameraCount,
    bool? isRecordingEnabled,
    bool? isPhysicallyReady,
    RunnerSource? runnerSource,
    String? runnerId,
    String? runnerName,
    int? fps,
    String? note,
    bool? isLongJump,
    AnchorResult? anchorResult,
    bool? isAllUploaded,
    bool clearAnchor = false,
    bool clearSharedRunSessionId = false,
    String? pendingControlRequestFrom,
    bool? isWaitingForControlApproval,
    bool clearPendingControlRequest = false,
  }) {
    return RecordState(
      role: role ?? this.role,
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      members: members ?? this.members,
      error: error,
      myDeviceInfoIndex: myDeviceInfoIndex ?? this.myDeviceInfoIndex,
      myCameraIndex: myCameraIndex ?? this.myCameraIndex,
      sharedRunSessionId: clearSharedRunSessionId
          ? null
          : (sharedRunSessionId ?? this.sharedRunSessionId),
      expectedCameraCount: expectedCameraCount ?? this.expectedCameraCount,
      isRecordingEnabled: isRecordingEnabled ?? this.isRecordingEnabled,
      isPhysicallyReady: isPhysicallyReady ?? this.isPhysicallyReady,
      runnerSource: runnerSource ?? this.runnerSource,
      runnerId: runnerId ?? this.runnerId,
      runnerName: runnerName ?? this.runnerName,
      fps: fps ?? this.fps,
      note: note ?? this.note,
      isLongJump: isLongJump ?? this.isLongJump,
      anchorResult: clearAnchor ? null : (anchorResult ?? this.anchorResult),
      isAllUploaded: isAllUploaded ?? this.isAllUploaded,
      pendingControlRequestFrom: clearPendingControlRequest
          ? null
          : (pendingControlRequestFrom ?? this.pendingControlRequestFrom),
      isWaitingForControlApproval:
          isWaitingForControlApproval ?? this.isWaitingForControlApproval,
    );
  }
}
