import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) => const AuthRepository());

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState.initial()) {
    _init();
  }

  // Called on app start — restore session from local storage
  Future<void> _init() async {
    state = const AuthState.loading();
    try {
      final user = await _repo.restoreSession();
      if (user != null) {
        state = AuthState.authenticated(user);
        // Silently refresh from API in background
        _refreshUser();
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> _refreshUser() async {
    try {
      final user = await _repo.getMe();
      state = AuthState.authenticated(user);
    } catch (_) {
      // Keep existing local user if refresh fails
    }
  }

  // Login
  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final user = await _repo.login(email: email, password: password);
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (_) {
      state = AuthState.error('Something went wrong. Please try again.');
    }
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
    int?    age,
    double? weight,
    double? height,
    String? gender,
    String? fitnessGoal,
    String? activityLevel,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _repo.register(
        name: name, email: email, password: password,
        age: age, weight: weight, height: height,
        gender: gender, fitnessGoal: fitnessGoal, activityLevel: activityLevel,
      );
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (_) {
      state = AuthState.error('Registration failed. Try again.');
    }
  }

  // Update profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = await _repo.updateProfile(data);
      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    }
  }

  // Logout
  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState.unauthenticated();
  }

  // Clear error
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState.unauthenticated();
    }
  }
}

// Main auth provider — used everywhere
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// Convenience providers
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});