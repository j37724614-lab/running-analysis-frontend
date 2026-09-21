import 'package:flutter_riverpod/legacy.dart';

final uploadSelectedRunnerIdProvider = StateProvider.autoDispose<String?>((ref) => null);

final uploadSelectedRunSessionIdProvider = StateProvider.autoDispose<String?>((ref) => null);

final uploadTourAnchorPlaceholderOpenProvider = StateProvider<bool>((ref) => false);
