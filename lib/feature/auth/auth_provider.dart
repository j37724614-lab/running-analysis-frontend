import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/utils/net_utils.dart';
import 'package:frontend/utils/api.dart';
import 'package:frontend/feature/guide/guide_tour_service.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';

  @override
  AuthState build() {
    NetUtils.onUnauthorized = () {
      logout();
    };
    // 非同步初始化狀態
    _init();
    return AuthState.initial();
  }

  Future<void> _init() async {
    state = AuthState.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final username = prefs.getString(_usernameKey);
      if (token != null && token.isNotEmpty && username != null) {
        try {
          final verifyResp = await NetUtils().reqeustData<Map<String, dynamic>>(
            '${API.baseUrl}/auth/verify',
            method: DioMethod.get,
          );
          if (verifyResp['seen_tours'] is List) {
            final seen = (verifyResp['seen_tours'] as List).map((e) => e.toString()).toList();
            await GuideTourService.syncSeenTours(seen);
          }
          state = AuthState.authenticated(token, username);
        } catch (_) {
          // Token is invalid/expired
          await prefs.remove(_tokenKey);
          await prefs.remove(_usernameKey);
          await GuideTourService.resetAllLocalTours();
          state = AuthState.unauthenticated();
        }
      } else {
        await GuideTourService.resetAllLocalTours();
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      await GuideTourService.resetAllLocalTours();
      state = AuthState.unauthenticated();
    }
  }

  Future<bool> login(String username, String password) async {
    state = AuthState.loading();
    try {
      final response = await NetUtils().reqeustData<Map<String, dynamic>>(
        '${API.baseUrl}/auth/login',
        method: DioMethod.post,
        postData: {'username': username, 'password': password},
      );

      final token = response['access_token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_usernameKey, username);

      try {
        final verifyResp = await NetUtils().reqeustData<Map<String, dynamic>>(
          '${API.baseUrl}/auth/verify',
          method: DioMethod.get,
        );
        if (verifyResp['seen_tours'] is List) {
          final seen = (verifyResp['seen_tours'] as List).map((e) => e.toString()).toList();
          await GuideTourService.syncSeenTours(seen);
        }
      } catch (_) {}

      state = AuthState.authenticated(token, username);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    state = AuthState.loading();
    try {
      await NetUtils().reqeustData<Map<String, dynamic>>(
        '${API.baseUrl}/auth/register',
        method: DioMethod.post,
        postData: {'username': username, 'password': password},
      );
      // 註冊成功後直接自動登入
      return await login(username, password);
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_usernameKey);
      await GuideTourService.resetAllLocalTours();
    } catch (_) {}
    state = AuthState.unauthenticated();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
