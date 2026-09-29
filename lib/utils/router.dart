import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/feature/home_page.dart';
import 'package:frontend/feature/playback/playback_page.dart';
import 'package:frontend/feature/upload/upload_page.dart';
import 'package:frontend/feature/record/record_page.dart';
import 'package:frontend/feature/splash/splash_page.dart';
import 'package:frontend/feature/policy/policy_page.dart';
import 'package:frontend/feature/support/support_page.dart';
import 'package:frontend/feature/auth/login_page.dart';
import 'package:frontend/feature/auth/register_page.dart';
import 'package:frontend/feature/auth/auth_provider.dart';
import 'package:frontend/feature/auth/auth_state.dart';
import 'package:frontend/feature/playback/playback_provider.dart';
import 'package:frontend/feature/upload/upload_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

enum AppRoute { playback, upload, record }

Page<dynamic> _buildFadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
          ),
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(
              parent: secondaryAnimation,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      if (previous?.status != next.status || previous?.username != next.username) {
        _ref.read(uploadSelectedRunnerIdProvider.notifier).state = null;
        _ref.read(uploadSelectedRunSessionIdProvider.notifier).state = null;
        _ref.read(uploadExternalSessionInfoProvider.notifier).state = null;
        _ref.read(playbackSelectedRunnerIdProvider.notifier).state = null;
        _ref.read(playbackSelectedRunSessionIdProvider.notifier).state = null;
      }
      notifyListeners();
    });
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: kIsWeb ? '/playback' : '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isLoggedIn = auth.status == AuthStatus.authenticated;
      final isLoggingIn = state.uri.path == '/login';
      final isRegistering = state.uri.path == '/register';

      // 載入期間或初始狀態不重導向
      if (auth.status == AuthStatus.loading || auth.status == AuthStatus.initial) {
        return null;
      }

      // 若在 Web 端透過頂層 URL Query 帶入 roomId 或 runSessionId
      if (kIsWeb &&
          state.uri.path != '/record' &&
          state.uri.path != '/upload' &&
          !isLoggingIn &&
          !isRegistering) {
        final baseRoomId = Uri.base.queryParameters['roomId'];
        if (baseRoomId != null && baseRoomId.isNotEmpty) {
          final cameraIndex =
              Uri.base.queryParameters['cameraIndex'] ?? Uri.base.queryParameters['camera'];
          final cameraQuery = cameraIndex != null ? '&cameraIndex=$cameraIndex' : '';
          final target = '/record?roomId=$baseRoomId$cameraQuery';
          if (!isLoggedIn) {
            return '/login?redirect=${Uri.encodeComponent(target)}';
          }
          return target;
        }

        final baseRunSessionId = Uri.base.queryParameters['runSessionId'];
        if (baseRunSessionId != null && baseRunSessionId.isNotEmpty) {
          final target = '/upload?runSessionId=$baseRunSessionId';
          if (!isLoggedIn) {
            return '/login?redirect=${Uri.encodeComponent(target)}';
          }
          return target;
        }
      }

      if (!isLoggedIn) {
        // 未登入：非登入/註冊/隱私/支援頁，強制導向登入頁
        if (!isLoggingIn &&
            !isRegistering &&
            state.uri.path != '/policy' &&
            state.uri.path != '/support') {
          final target = state.uri.toString();
          if (target.isNotEmpty && target != '/' && target != '/playback') {
            return '/login?redirect=${Uri.encodeComponent(target)}';
          }
          return '/login';
        }
      } else {
        // 已登入：若造訪登入或註冊頁，重導向至 redirect 目標或主畫面
        if (isLoggingIn || isRegistering) {
          final redirect = state.uri.queryParameters['redirect'];
          if (redirect != null && redirect.isNotEmpty) {
            return Uri.decodeComponent(redirect);
          }
          return '/playback';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildFadePage(state, const SplashPage()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildFadePage(state, const LoginPage()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _buildFadePage(state, const RegisterPage()),
      ),
      GoRoute(
        path: '/policy',
        pageBuilder: (context, state) => _buildFadePage(state, const PolicyPage()),
      ),
      GoRoute(
        path: '/support',
        pageBuilder: (context, state) => _buildFadePage(state, const SupportPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => HomePage(child: child),
        routes: [
          GoRoute(
            path: '/playback',
            name: AppRoute.playback.name,
            pageBuilder: (context, state) {
              final runnerId = state.uri.queryParameters['runnerId'];
              final videoId = state.uri.queryParameters['videoId'];
              return _buildFadePage(state, PlaybackPage(runnerId: runnerId, videoId: videoId));
            },
          ),
          GoRoute(
            path: '/upload',
            name: AppRoute.upload.name,
            pageBuilder: (context, state) {
              final runSessionId =
                  state.uri.queryParameters['runSessionId'] ??
                  (kIsWeb ? Uri.base.queryParameters['runSessionId'] : null);
              return _buildFadePage(
                state,
                UploadPage(
                  key: ValueKey('upload_${runSessionId ?? "none"}'),
                  runSessionId: runSessionId,
                ),
              );
            },
          ),
          GoRoute(
            path: '/record',
            name: AppRoute.record.name,
            pageBuilder: (context, state) {
              final roomId =
                  state.uri.queryParameters['roomId'] ??
                  (kIsWeb ? Uri.base.queryParameters['roomId'] : null);
              final cameraParam =
                  state.uri.queryParameters['cameraIndex'] ??
                  state.uri.queryParameters['camera'] ??
                  (kIsWeb
                      ? Uri.base.queryParameters['cameraIndex'] ??
                            Uri.base.queryParameters['camera']
                      : null);
              final cameraIndex = cameraParam != null ? int.tryParse(cameraParam) : null;
              return _buildFadePage(
                state,
                RecordPage(
                  key: ValueKey('record_${roomId ?? "none"}_${cameraIndex ?? "none"}'),
                  initialRoomId: roomId,
                  initialCameraIndex: cameraIndex,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
});
