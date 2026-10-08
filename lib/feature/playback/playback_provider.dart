import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show FutureProvider;
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/comparison_report.dart';

final playbackSelectedRunnerIdProvider = StateProvider<String?>((ref) => null);

final playbackSelectedRunSessionIdProvider = StateProvider<String?>((ref) => null);

final playbackSidebarExpandedProvider = StateProvider<bool>((ref) => false);

final comparisonReportProvider = FutureProvider.family<ComparisonReport, String>(
  (ref, comparisonGroupId) => ref.watch(backendProvider).getComparisonReport(comparisonGroupId),
);
