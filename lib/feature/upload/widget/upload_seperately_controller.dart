import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/backend/backend_interface.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/upload_video_file.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';
import 'package:frontend/utils/api.dart';
import 'package:frontend/feature/auth/auth_provider.dart';

class UploadSeperatelyState {
  final String? thumbnail;
  final String? tempVideoId;
  final bool isUploading;
  final String? error;
  final AnchorResult? anchorResult;

  UploadSeperatelyState({
    required this.thumbnail,
    required this.tempVideoId,
    this.isUploading = false,
    this.error,
    this.anchorResult,
  });

  factory UploadSeperatelyState.initial() =>
      UploadSeperatelyState(thumbnail: null, tempVideoId: null);

  UploadSeperatelyState copyWith({
    String? thumbnail,
    String? tempVideoId,
    bool? isUploading,
    String? error,
    AnchorResult? anchorResult,
    bool clearAnchor = false,
  }) {
    return UploadSeperatelyState(
      thumbnail: thumbnail ?? this.thumbnail,
      tempVideoId: tempVideoId ?? this.tempVideoId,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      anchorResult: clearAnchor ? null : (anchorResult ?? this.anchorResult),
    );
  }
}

class UploadSeperatelyController extends StateNotifier<UploadSeperatelyState> {
  final BackendInterface backend;
  final Ref ref;

  UploadSeperatelyController(this.backend, this.ref) : super(UploadSeperatelyState.initial());

  Future<void> uploadVideo(int index, UploadVideoFile file) async {
    state = state.copyWith(isUploading: true, error: null);

    try {
      final tempVideoId = await backend.uploadVideo(index, file);
      var thumbnailUrl = API.getTempVideoThumbnail(tempVideoId)[1] as String;
      final token = ref.read(authProvider).token;
      if (token != null && token.isNotEmpty) {
        final separator = thumbnailUrl.contains('?') ? '&' : '?';
        thumbnailUrl = '$thumbnailUrl${separator}token=$token';
      }

      state = state.copyWith(thumbnail: thumbnailUrl, tempVideoId: tempVideoId, isUploading: false);
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
    }
  }

  void resetState() {
    state = UploadSeperatelyState.initial();
  }

  void setAnchor(AnchorResult? result) {
    if (result == null) {
      state = state.copyWith(clearAnchor: true);
    } else {
      state = state.copyWith(anchorResult: result);
    }
  }
}

final uploadSeperatelyControllerProvider =
    StateNotifierProvider.autoDispose<UploadSeperatelyController, UploadSeperatelyState>((ref) {
      final backend = ref.watch(backendProvider);
      return UploadSeperatelyController(backend, ref);
    });
