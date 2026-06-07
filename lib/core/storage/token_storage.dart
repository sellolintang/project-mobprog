import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _biometricEnabledKey = 'biometric_enabled';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUserData({
    required String role,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _nameKey, value: name);
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<String?> getName() async {
    return await _storage.read(key: _nameKey);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<void> saveBiometricEnabled(bool value) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: value ? 'true' : 'false',
    );
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<void> clearBiometricEnabled() async {
    await _storage.delete(key: _biometricEnabledKey);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}