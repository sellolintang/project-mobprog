import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../core/storage/token_storage.dart';
import '../core/notifications/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;
  final BiometricService _biometricService;

  AuthProvider({
    AuthService? authService,
    TokenStorage? tokenStorage,
    BiometricService? biometricService,
  })  : _authService = authService ?? AuthService(),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        _biometricService = biometricService ?? BiometricService();

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => user != null;
  String? get role => user?.role;

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      user = await _authService.login(
        email: email,
        password: password,
      );

      final canUseBiometric = await _biometricService.canUseBiometric();
      await _tokenStorage.saveBiometricEnabled(canUseBiometric);

      await NotificationService.showNotification(
        title: 'Login Berhasil',
        body: 'Selamat datang, ${user!.name}',
      );

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      final token = await _tokenStorage.getToken();

      if (token == null || token.isEmpty) {
        user = null;
        notifyListeners();
        return;
      }

      user = await _authService.getMe();
      notifyListeners();
    } catch (_) {
      await _tokenStorage.clear();
      user = null;
      notifyListeners();
    }
  }

  Future<bool> canUseBiometricLogin() async {
    final token = await _tokenStorage.getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    final biometricEnabled = await _tokenStorage.isBiometricEnabled();

    if (!biometricEnabled) {
      return false;
    }

    return await _biometricService.canUseBiometric();
  }

  Future<bool> biometricLogin() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final canUse = await canUseBiometricLogin();

      if (!canUse) {
        isLoading = false;
        errorMessage = 'Biometric login belum tersedia di perangkat ini.';
        notifyListeners();
        return false;
      }

      final authenticated = await _biometricService.authenticate();

      if (!authenticated) {
        isLoading = false;
        errorMessage = 'Autentikasi biometric dibatalkan atau gagal.';
        notifyListeners();
        return false;
      }

      user = await _authService.getMe();

      await NotificationService.showNotification(
        title: 'Login Biometric Berhasil',
        body: 'Selamat datang kembali, ${user!.name}',
      );

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> canDeviceUseBiometric() async {
    return await _biometricService.canUseBiometric();
  }

  Future<bool> isBiometricEnabled() async {
    return await _tokenStorage.isBiometricEnabled();
  }

  Future<void> enableBiometricLogin() async {
    final canUse = await _biometricService.canUseBiometric();
    await _tokenStorage.saveBiometricEnabled(canUse);
    notifyListeners();
  }

  Future<void> disableBiometricLogin() async {
    await _tokenStorage.saveBiometricEnabled(false);
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.forgotPassword(email: email);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      user = null;

      await NotificationService.showNotification(
        title: 'Logout Berhasil',
        body: 'Anda telah keluar dari aplikasi.',
      );

      notifyListeners();
    }
  }
}