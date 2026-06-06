import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : apiClient = apiClient ?? ApiClient(),
        tokenStorage = tokenStorage ?? TokenStorage();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;

      final token = data['token'];
      final userJson = data['user'];

      if (token == null || userJson == null) {
        throw Exception('Response login tidak sesuai.');
      }

      final user = UserModel.fromJson(userJson);

      await tokenStorage.saveToken(token);
      await tokenStorage.saveUserData(
        role: user.role,
        name: user.name,
        email: user.email,
      );

      return user;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login gagal.';
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.me);

      final data = response.data;
      final userJson = data['user'] ?? data['data'];

      if (userJson == null) {
        throw Exception('Data user tidak ditemukan.');
      }

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Gagal mengambil data user.';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post(ApiConstants.logout);
    } finally {
      await tokenStorage.clear();
    }
  }
}