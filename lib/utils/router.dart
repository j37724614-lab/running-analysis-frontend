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

      if (!isLoggedIn) {
        // 未登入：非登入/註冊/隱私/支援頁，強制導向登入頁
        if (!isLoggingIn &&
            !isRegistering &&
            state.uri.path != '/policy' &&
            state.uri.path != '/support') {
          return '/login';
        }
      } else {
        // 已登入：若造訪登入或註冊頁，重導向至主畫面
        if (isLoggingIn || isRegistering) {
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
              return _buildFadePage(state, const UploadPage());
            },
          ),
          GoRoute(
            path: '/record',
            name: AppRoute.record.name,
            pageBuilder: (context, state) {
              return _buildFadePage(state, const RecordPage());
            },
          ),
        ],
      ),
    ],
  );
});
