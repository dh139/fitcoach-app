import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String?    error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  const AuthState.initial()         : status = AuthStatus.initial,        user = null, error = null;
  const AuthState.loading()         : status = AuthStatus.loading,        user = null, error = null;
  AuthState.authenticated(UserModel u) : status = AuthStatus.authenticated, user = u,    error = null;
  const AuthState.unauthenticated() : status = AuthStatus.unauthenticated, user = null, error = null;
  AuthState.error(String msg)       : status = AuthStatus.error,          user = null, error = msg;

  bool get isAuthenticated  => status == AuthStatus.authenticated;
  bool get isLoading        => status == AuthStatus.loading;
  bool get isUnauthenticated=> status == AuthStatus.unauthenticated || status == AuthStatus.error;

  AuthState copyWithUser(UserModel u) => AuthState(status: AuthStatus.authenticated, user: u);

  @override
  String toString() => 'AuthState($status, user:${user?.name}, error:$error)';
}