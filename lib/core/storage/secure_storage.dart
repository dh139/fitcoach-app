import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  SecureStorage._();
  static final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void>    saveToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);

  static Future<String?> getToken() =>
      _storage.read(key: AppConstants.tokenKey);

  static Future<void>    deleteToken() =>
      _storage.delete(key: AppConstants.tokenKey);

  static Future<void>    saveUser(String json) =>
      _storage.write(key: AppConstants.userKey, value: json);

  static Future<String?> getUser() =>
      _storage.read(key: AppConstants.userKey);

  static Future<void>    deleteUser() =>
      _storage.delete(key: AppConstants.userKey);

  static Future<void>    clearAll() => _storage.deleteAll();
}