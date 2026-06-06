import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/storage/token_storage.dart';
import '../core/notifications/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthProvider({
    AuthService? authService,
    TokenStorage? tokenStorage,
  })  : authService = authService ?? AuthService(),
        tokenStorage = tokenStorage ?? TokenStorage();

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

      user = await authService.login(
        email: email,
        password: password,
      );

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
      final token = await tokenStorage.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      user = await authService.getMe();
      notifyListeners();
    } catch (_) {
      await tokenStorage.clear();
      user = null;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authService.logout();
    user = null;

    await NotificationService.showNotification(
      title: 'Logout Berhasil',
      body: 'Anda telah keluar dari aplikasi.',
    );

    notifyListeners();
  }
}