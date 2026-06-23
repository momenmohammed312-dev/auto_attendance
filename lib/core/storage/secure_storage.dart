import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// SecureStorageService
///
/// دي wrapper class عشان نتعامل مع flutter_secure_storage
/// بنخزن فيها:
/// - الـ JWT Token
/// - بيانات الـ User (مشفر)
/// - إعدادات التطبيق الحساسة
class SecureStorageService {
  // Singleton pattern - عشان ما نعملش أكتر من instance
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // الـ Storage نفسه
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // تشفير على Android
    ),
    iOptions: IOSOptions(
      accountName: 'flutter_secure_storage', // Keychain account
    ),
  );

  // Keys اللي هنستخدمها
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _rememberMeKey = 'remember_me';

  /// ==================== USER DATA ====================

  /// Save user data after successful login
  /// بنخزن الـ User كـ JSON string مشفر
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final String userJson = jsonEncode(userData);
    await _storage.write(key: _userKey, value: userJson);
  }

  /// Get saved user data
  /// بترجع Map لو فيه يوزر، أو null لو مفيش
  Future<Map<String, dynamic>?> getUser() async {
    final String? userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Delete user data (on logout)
  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  /// ==================== JWT TOKEN ====================

  /// Save JWT token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// ==================== REFRESH TOKEN ====================

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// ==================== REMEMBER ME ====================

  /// Save remember me preference
  Future<void> setRememberMe(bool value) async {
    await _storage.write(key: _rememberMeKey, value: value.toString());
  }

  /// Get remember me preference
  Future<bool> getRememberMe() async {
    final String? value = await _storage.read(key: _rememberMeKey);
    return value == 'true';
  }

  /// ==================== CLEAR ALL ====================

  /// Clear everything (on logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

// Global instance for easy access
final secureStorage = SecureStorageService();
