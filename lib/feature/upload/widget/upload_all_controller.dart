import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/backend/backend_interface.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/upload_video_file.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';
import 'package:frontend/utils/api.dart';
import 'package:frontend/feature/auth/auth_provider.dart';

class UploadThumbnailState {
  final String? thumbnailUrl;
  final String? tempVideoId;
  final bool isUploading;
  final String? error;
  final AnchorResult? anchorResult;

  const UploadThumbnailState({
    this.thumbnailUrl,
    this.tempVideoId,
    this.isUploading = false,
    this.error,
    this.anchorResult,
  });

  UploadThumbnailState copyWith({
    String? thumbnailUrl,
    String? tempVideoId,
    bool? isUploading,
    String? error,
    AnchorResult? anchorResult,
    bool clearAnchor = false,
  }) {
    return UploadThumbnailState(
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      tempVideoId: tempVideoId ?? this.tempVideoId,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      anchorResult: clearAnchor ? null : (anchorResult ?? this.anchorResult),
    );
  }
}

class UploadAllState {
  final List<UploadThumbnailState> tempVideoStates;
  final int cameraCount;
  final bool isUploadingAll; // 給 uploadAllInfo 用
  final String? error;

  UploadAllState({
    required this.tempVideoStates,
    required this.cameraCount,
    this.isUploadingAll = false,
    this.error,
  });

  factory UploadAllState.initial() => UploadAllState(
    tempVideoStates: List.generate(5, (_) => const UploadThumbnailState()),
    cameraCount: 5,
  );

  UploadAllState copyWith({
    List<UploadThumbnailState>? tempVideoStates,
    int? cameraCount,
    bool? isUploadingAll,
    String? error,
  }) {
    return UploadAllState(
      tempVideoStates: tempVideoStates ?? this.tempVideoStates,
      cameraCount: cameraCount ?? this.cameraCount,
      isUploadingAll: isUploadingAll ?? this.isUploadingAll,
      error: error,
    );
  }
}

class UploadAllController extends StateNotifier<UploadAllState> {
  final BackendInterface backend;
  final Ref ref;

  UploadAllController(this.backend, this.ref) : super(UploadAllState.initial());

  void setCameraCount(int count) {
    if (count == state.cameraCount) return;

    final currentStates = [...state.tempVideoStates];
    final List<UploadThumbnailState> newStates;

    if (count > state.cameraCount) {
      // 增加數量：補上空的狀態
      newStates = [
        ...currentStates,
        ...List.generate(count - state.cameraCount, (_) => const UploadThumbnailState()),
      ];
    } else {
      // 減少數量：直接截斷
      newStates = currentStates.sublist(0, count);
    }

    state = state.copyWith(tempVideoStates: newStates, cameraCount: count);
  }

  Future<void> uploadVideo(int index, UploadVideoFile file) async {
    final updated = [...state.tempVideoStates];
    updated[index] = updated[index].copyWith(isUploading: true, error: null);
    state = state.copyWith(tempVideoStates: updated);

    try {
      final tempVideoId = await backend.uploadVideo(index, file);
      var thumbnailUrl = API.getTempVideoThumbnail(tempVideoId)[1] as String;
      final token = ref.read(authProvider).token;
      if (token != null && token.isNotEmpty) {
        final separator = thumbnailUrl.contains('?') ? '&' : '?';
        thumbnailUrl = '$thumbnailUrl${separator}token=$token';
      }

      updated[index] = updated[index].copyWith(
        thumbnailUrl: thumbnailUrl,
        tempVideoId: tempVideoId,
        isUploading: false,
      );
      state = state.copyWith(tempVideoStates: updated);
    } catch (e) {
      updated[index] = updated[index].copyWith(isUploading: false, error: e.toString());
      state = state.copyWith(tempVideoStates: updated);
    }
  }

  /// 設定某個相機的錨點結果
  void setAnchor(int index, AnchorResult? result) {
    final updated = [...state.tempVideoStates];
    if (result == null) {
      updated[index] = updated[index].copyWith(clearAnchor: true);
    } else {
      updated[index] = updated[index].copyWith(anchorResult: result);
    }
    state = state.copyWith(tempVideoStates: updated);
  }
}

final uploadAllControllerProvider =
    StateNotifierProvider.autoDispose<UploadAllController, UploadAllState>((ref) {
      final backend = ref.watch(backendProvider);
      return UploadAllController(backend, ref);
    });
