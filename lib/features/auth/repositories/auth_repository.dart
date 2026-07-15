import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override String toString() => message;
}

class AuthRepository {
  const AuthRepository();

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await ApiClient.post(ApiEndpoints.login, data: {
        'email':    email.trim().toLowerCase(),
        'password': password,
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final token = res.data['token'] as String;
        final user  = UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
        await SecureStorage.saveToken(token);
        await SecureStorage.saveUser(user.toJsonString());
        return user;
      }

      throw AuthException(
        res.data['message'] as String? ?? 'Login failed',
      );
    } on DioException catch (e) {
      throw AuthException(
        e.response?.data?['message'] as String? ?? 'Network error — check your connection',
      );
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    int?    age,
    double? weight,
    double? height,
    String? gender,
    String? fitnessGoal,
    String? activityLevel,
    String? role,
  }) async {
    try {
      final res = await ApiClient.post(ApiEndpoints.register, data: {
        'name':          name.trim(),
        'email':         email.trim().toLowerCase(),
        'password':      password,
        if (age          != null) 'age':           age,
        if (weight       != null) 'weight':        weight,
        if (height       != null) 'height':        height,
        if (gender       != null) 'gender':        gender,
        if (fitnessGoal  != null) 'fitnessGoal':   fitnessGoal,
        if (activityLevel!= null) 'activityLevel': activityLevel,
        if (role         != null) 'role':          role,
      });

      if (res.statusCode == 201 && res.data['success'] == true) {
        final token = res.data['token'] as String;
        final user  = UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
        await SecureStorage.saveToken(token);
        await SecureStorage.saveUser(user.toJsonString());
        return user;
      }

      throw AuthException(
        res.data['message'] as String? ?? 'Registration failed',
      );
    } on DioException catch (e) {
      throw AuthException(
        e.response?.data?['message'] as String? ?? 'Network error — check your connection',
      );
    }
  }

  // ── Get current user from API ──────────────────────────────────────────────
  Future<UserModel> getMe() async {
    try {
      final res = await ApiClient.get(ApiEndpoints.me);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final user = UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
        await SecureStorage.saveUser(user.toJsonString());
        return user;
      }
      throw const AuthException('Session expired — please log in again');
    } on DioException catch (_) {
      throw const AuthException('Could not refresh session');
    }
  }

  // ── Restore from local storage ─────────────────────────────────────────────
  Future<UserModel?> restoreSession() async {
    final token   = await SecureStorage.getToken();
    final userStr = await SecureStorage.getUser();
    if (token == null || userStr == null) return null;
    try {
      return UserModel.fromJsonString(userStr);
    } catch (_) {
      return null;
    }
  }

  // ── Update profile ─────────────────────────────────────────────────────────
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await ApiClient.put(ApiEndpoints.updateProfile, data: data);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final user = UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
        await SecureStorage.saveUser(user.toJsonString());
        return user;
      }
      throw AuthException(res.data['message'] as String? ?? 'Update failed');
    } on DioException catch (e) {
      throw AuthException(e.response?.data?['message'] as String? ?? 'Network error');
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() => SecureStorage.clearAll();
}