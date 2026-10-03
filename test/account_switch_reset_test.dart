import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/entities/unanalyzed_run_session_info.dart';
import 'package:frontend/feature/auth/auth_provider.dart';
import 'package:frontend/feature/auth/auth_state.dart';
import 'package:frontend/feature/playback/playback_provider.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/feature/upload/upload_provider.dart';
import 'package:frontend/utils/router.dart';

/// Auth notifier that skips SharedPreferences / token verification so tests
/// can drive login, logout and account switches directly.
class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState.authenticated('token-a', 'alice');

  void setAuth(AuthState next) => state = next;
}

final _routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

ProviderContainer _createContainer() {
  final container = ProviderContainer(
    overrides: [authProvider.overrideWith(_TestAuthNotifier.new)],
  );
  addTearDown(container.dispose);

  // Upload selections are autoDispose; keep them alive like a mounted page would.
  container.listen(uploadSelectedRunnerIdProvider, (_, _) {});
  container.listen(uploadSelectedRunSessionIdProvider, (_, _) {});
  container.listen(uploadExternalSessionInfoProvider, (_, _) {});
  container.read(_routerNotifierProvider);
  return container;
}

void _selectEverything(ProviderContainer container) {
  container.read(uploadSelectedRunnerIdProvider.notifier).state = 'runner-a';
  container.read(uploadSelectedRunSessionIdProvider.notifier).state = 'session-a';
  container.read(uploadExternalSessionInfoProvider.notifier).state = UnanalyzedRunSessionInfo(
    runSessionId: 'external-a',
    runnerId: 'runner-x',
    runnerName: 'X',
    date: DateTime(2026),
    cameraCount: 2,
    fps: 60,
    note: '',
    unuploadedCameraIndexes: [1],
    videoPaths: ['video-0', null],
  );
  container.read(playbackSelectedRunnerIdProvider.notifier).state = 'runner-a';
  container.read(playbackSelectedRunSessionIdProvider.notifier).state = 'session-a';
  container.read(trialReviewSelectedRunnerIdProvider.notifier).state = 'runner-a';
  container.read(trialReviewSelectedRunSessionIdProvider.notifier).state = 'session-a';
  container.read(trialReviewComparisonIdsProvider.notifier).state = {'session-b', 'session-c'};
}

void _expectEverythingCleared(ProviderContainer container) {
  expect(container.read(uploadSelectedRunnerIdProvider), isNull);
  expect(container.read(uploadSelectedRunSessionIdProvider), isNull);
  expect(container.read(uploadExternalSessionInfoProvider), isNull);
  expect(container.read(playbackSelectedRunnerIdProvider), isNull);
  expect(container.read(playbackSelectedRunSessionIdProvider), isNull);
  expect(container.read(trialReviewSelectedRunnerIdProvider), isNull);
  expect(container.read(trialReviewSelectedRunSessionIdProvider), isNull);
  expect(container.read(trialReviewComparisonIdsProvider), isEmpty);
}

void main() {
  test('switching to another account clears playback, upload and trial review selections', () {
    final container = _createContainer();
    _selectEverything(container);

    (container.read(authProvider.notifier) as _TestAuthNotifier).setAuth(
      AuthState.authenticated('token-b', 'bob'),
    );

    _expectEverythingCleared(container);
  });

  test('logging out clears playback, upload and trial review selections', () {
    final container = _createContainer();
    _selectEverything(container);

    (container.read(authProvider.notifier) as _TestAuthNotifier).setAuth(
      AuthState.unauthenticated(),
    );

    _expectEverythingCleared(container);
  });

  test('refreshing the token for the same account keeps selections', () {
    final container = _createContainer();
    _selectEverything(container);

    (container.read(authProvider.notifier) as _TestAuthNotifier).setAuth(
      AuthState.authenticated('token-a-refreshed', 'alice'),
    );

    expect(container.read(trialReviewSelectedRunnerIdProvider), 'runner-a');
    expect(container.read(uploadSelectedRunnerIdProvider), 'runner-a');
  });
}
