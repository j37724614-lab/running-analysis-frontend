enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? token;
  final String? username;
  final String? errorMessage;

  const AuthState({required this.status, this.token, this.username, this.errorMessage});

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  factory AuthState.authenticated(String token, String username) {
    return AuthState(status: AuthStatus.authenticated, token: token, username: username);
  }

  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  factory AuthState.error(String message) {
    return AuthState(status: AuthStatus.error, errorMessage: message);
  }

  AuthState copyWith({AuthStatus? status, String? token, String? username, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      username: username ?? this.username,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
