import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/entities/unanalyzed_run_session_info.dart';

final uploadSelectedRunnerIdProvider = StateProvider.autoDispose<String?>((ref) => null);

final uploadSelectedRunSessionIdProvider = StateProvider.autoDispose<String?>((ref) => null);

final uploadExternalSessionInfoProvider = StateProvider.autoDispose<UnanalyzedRunSessionInfo?>(
  (ref) => null,
);

final uploadTourAnchorPlaceholderOpenProvider = StateProvider<bool>((ref) => false);
