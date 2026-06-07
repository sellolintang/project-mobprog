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

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;

      if (errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
    }

    return fallback;
  }

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

      final responseData = response.data;

      if (responseData is! Map || responseData['data'] is! Map) {
        throw Exception('Format response login tidak sesuai.');
      }

      final data = Map<String, dynamic>.from(responseData['data']);

      final token = data['token'];
      final userJson = data['user'];

      if (token == null || userJson == null || userJson is! Map) {
        throw Exception('Token atau data user tidak ditemukan.');
      }

      final user = UserModel.fromJson(
        Map<String, dynamic>.from(userJson),
      );

      await tokenStorage.saveToken(token.toString());
      await tokenStorage.saveUserData(
        role: user.role,
        name: user.name,
        email: user.email,
      );

      return user;
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Login gagal. Periksa email dan password.'),
      );
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.me);

      final responseData = response.data;

      if (responseData is! Map || responseData['data'] is! Map) {
        throw Exception('Format response user tidak sesuai.');
      }

      final data = Map<String, dynamic>.from(responseData['data']);
      final userJson = data['user'];

      if (userJson == null || userJson is! Map) {
        throw Exception('Data user tidak ditemukan.');
      }

      return UserModel.fromJson(
        Map<String, dynamic>.from(userJson),
      );
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil data user.'),
      );
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.forgotPassword,
        data: {
          'email': email,
        },
      );

      final responseData = response.data;

      if (responseData is Map && responseData['message'] != null) {
        return responseData['message'].toString();
      }

      return 'Instruksi reset password telah dikirim ke email Anda.';
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(
          e,
          'Gagal mengirim instruksi reset password.',
        ),
      );
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
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