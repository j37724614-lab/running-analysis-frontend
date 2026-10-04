import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Which pipeline(s) compute a run's analysis (規劃書 Step 11,
/// runner-pose-ondevice/report/integration_guide.md §13).
///
/// `compare` means "both Server and Local run", not a third pipeline of its
/// own - [AnalysisRunController] fans out to both adapters for it. Kept as a
/// single enum (not two independent booleans) so "neither selected" can't
/// happen and the UI always has exactly one of three choices to render as a
/// segmented control / radio group (規劃書 §1 第 4 點).
enum AnalysisMode { server, local, compare }

final localAnalysisFeatureEnabledProvider = Provider<bool>(
  (_) => const bool.fromEnvironment('ENABLE_LOCAL_ANALYSIS', defaultValue: false),
);

final compareAnalysisFeatureEnabledProvider = Provider<bool>(
  (_) => const bool.fromEnvironment('ENABLE_COMPARE_ANALYSIS', defaultValue: false),
);

final uploadAnalysisModeProvider = StateProvider.autoDispose<AnalysisMode>(
  (_) => AnalysisMode.server,
);
