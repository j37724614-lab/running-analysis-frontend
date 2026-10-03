import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_interface.dart';
import 'package:frontend/backend/fake_backend_repo.dart';
import 'package:frontend/backend/rest_backend_repo.dart';
import 'package:frontend/entities/graph_data.dart';
import 'package:frontend/entities/runner_info.dart';
import 'package:frontend/entities/unanalyzed_run_session_info.dart';
import 'package:frontend/entities/run_session_info.dart';
import 'package:frontend/feature/auth/auth_provider.dart';
import 'package:frontend/utils/api_retry.dart';
import 'package:frontend/utils/config.dart';

final backendProvider = Provider<BackendInterface>((ref) {
  final backendRepo = kUseFakeRepos ? FakeBackendRepo() : RestBackendRepo();
  return backendRepo;
});

final runnerProvider = FutureProvider.autoDispose<List<RunnerInfo>>((ref) {
  ref.watch(authProvider);
  final backend = ref.watch(backendProvider);
  return backend.getRunners();
}, retry: apiRetry);

final graphDataProvider = FutureProvider.autoDispose.family<List<GraphData>, String>((
  ref,
  runSessionId,
) {
  final backend = ref.watch(backendProvider);
  return backend.getGraphData(runSessionId);
}, retry: apiRetry);

final videoInfoProvider = FutureProvider.autoDispose.family<RunSessionInfo, String>((
  ref,
  runSessionId,
) async {
  final backend = ref.watch(backendProvider);
  final info = await backend.getRunSessionInfo(runSessionId);

  // If status is processing, poll every 5 seconds
  if (info.status == 'processing') {
    final timer = Timer(const Duration(seconds: 5), () {
      ref.invalidateSelf();
    });
    ref.onDispose(timer.cancel);
  }

  return info;
}, retry: apiRetry);

final runnerHistoryProvider = FutureProvider.autoDispose.family<List<RunSessionInfo>, String>((
  ref,
  runnerId,
) async {
  final backend = ref.watch(backendProvider);
  final history = await backend.getRunnerHistory(runnerId);

  // If any video is processing, poll every 5 seconds
  if (history.any((info) => info.status == 'processing')) {
    final timer = Timer(const Duration(seconds: 5), () {
      ref.invalidateSelf();
    });
    ref.onDispose(timer.cancel);
  }

  return history;
}, retry: apiRetry);

final runnerUnanalyzedHistoryProvider = FutureProvider.autoDispose
    .family<List<UnanalyzedRunSessionInfo>, String>((ref, runnerId) {
      final backend = ref.watch(backendProvider);
      return backend.getRunnerUnanalyzedHistory(runnerId);
    }, retry: apiRetry);
