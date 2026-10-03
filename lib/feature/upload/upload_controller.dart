import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/backend/backend_interface.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/runner_info.dart';
import 'package:frontend/entities/upload_seperately_status.dart';
import 'package:frontend/utils/combine_date_and_time.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';
import 'package:frontend/feature/upload/upload_completion.dart';

class UploadController extends StateNotifier<AsyncValue<void>> {
  UploadController({required this.backend, required this.onUploadCompleted})
    : super(const AsyncValue.data(null));
  final BackendInterface backend;
  final void Function(String runnerId, String runSessionId) onUploadCompleted;

  Future<UploadSeperatelyStatus?> uploadSeperatelyNew(
    String runnerId,
    DateTime date,
    TimeOfDay time,
    int cameraCount,
    int fps,
    String note,
    bool isLongJump,
    int cameraIndex,
    String tempVideoId,
    AnchorResult? anchors,
  ) async {
    try {
      state = const AsyncLoading();
      final status = await backend.uploadSeperatelyNew(
        runnerId,
        combineDateAndTime(date, time),
        cameraCount,
        fps,
        note,
        isLongJump,
        cameraIndex,
        tempVideoId,
        anchors,
      );
      state = const AsyncValue.data(null);
      if (status.isAllUploaded) {
        onUploadCompleted(runnerId, status.runSessionId);
      }
      return status;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<UploadSeperatelyStatus?> uploadSeperatelySelect(
    String runnerId,
    String runSessionId,
    int cameraIndex,
    String tempVideoId,
    AnchorResult? anchors,
  ) async {
    try {
      state = const AsyncLoading();
      final status = await backend.uploadSeperatelySelect(
        runnerId,
        runSessionId,
        cameraIndex,
        tempVideoId,
        anchors,
      );
      state = const AsyncValue.data(null);
      if (status.isAllUploaded) {
        onUploadCompleted(runnerId, status.runSessionId);
      }
      return status;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<String?> uploadAllInfo(
    String runnerId,
    DateTime date,
    TimeOfDay time,
    int cameraCount,
    int fps,
    String note,
    bool isLongJump,
    List<Map<String, dynamic>> videos,
  ) async {
    try {
      state = const AsyncLoading();
      final videoId = await backend.uploadAllInfo(
        runnerId,
        combineDateAndTime(date, time),
        cameraCount,
        fps,
        note,
        isLongJump,
        videos,
      );
      state = const AsyncValue.data(null);
      onUploadCompleted(runnerId, videoId);
      return videoId;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }
}

final uploadControllerProvider =
    StateNotifierProvider<UploadController, AsyncValue<void>>((ref) {
      return UploadController(
        backend: ref.watch(backendProvider),
        onUploadCompleted: (runnerId, runSessionId) {
          ref
              .read(uploadCompletionProvider.notifier)
              .publish(runnerId: runnerId, runSessionId: runSessionId);
        },
      );
    });

class UploadRunnerListNotifier
    extends StateNotifier<AsyncValue<List<RunnerInfo>>> {
  final BackendInterface backend;

  UploadRunnerListNotifier(this.backend) : super(const AsyncValue.loading()) {
    loadRunners();
  }

  Future<void> loadRunners() async {
    final runners = await backend.getRunners();
    state = AsyncValue.data(runners);
  }

  Future<RunnerInfo> addRunner(String name) async {
    final newRunner = await backend.addRunner(name);
    state = AsyncValue.data([
      ...state.value!,
      RunnerInfo(name: name, id: newRunner, lastVideoId: ''),
    ]);
    return RunnerInfo(name: name, id: newRunner, lastVideoId: '');
  }
}

final uploadRunnerListProvider =
    StateNotifierProvider<
      UploadRunnerListNotifier,
      AsyncValue<List<RunnerInfo>>
    >((ref) => UploadRunnerListNotifier(ref.watch(backendProvider)));
