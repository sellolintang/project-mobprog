import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/jury_model.dart';

class JuryService {
  final ApiClient apiClient;

  JuryService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return fallback;
  }

  List _extractList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }

    if (responseData is Map && responseData['data'] is List) {
      return responseData['data'];
    }

    if (responseData is Map &&
        responseData['data'] is Map &&
        responseData['data']['data'] is List) {
      return responseData['data']['data'];
    }

    if (responseData is Map &&
        responseData['data'] is Map &&
        responseData['data']['items'] is List) {
      return responseData['data']['items'];
    }

    return [];
  }

  Future<List<JuryModel>> getJuries({
    int? periodId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'per_page': 100,
      };

      if (periodId != null) {
        queryParams['period_id'] = periodId;
      }

      final response = await apiClient.dio.get(
        ApiConstants.juries,
        queryParameters: queryParams,
      );

      final data = _extractList(response.data);

      return data
          .map(
            (item) => JuryModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal mengambil data juri.'));
    }
  }

  Future<void> createJury({
    required int periodId,
    required String name,
    required String email,
    required String phone,
    required String password,
    required bool isActive,
    required List<int> criteriaIds,
  }) async {
    try {
      await apiClient.dio.post(
        ApiConstants.juries,
        data: {
          'period_id': periodId,
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': password,
          'is_active': isActive,
          'criteria': criteriaIds,
        },
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal menambahkan akun juri.'));
    }
  }

  Future<void> updateJury({
    required int id,
    required int periodId,
    required String name,
    required String email,
    required String phone,
    String? password,
    required bool isActive,
    required List<int> criteriaIds,
  }) async {
    try {
      final data = {
        'period_id': periodId,
        'name': name,
        'email': email,
        'phone': phone,
        'is_active': isActive,
        'criteria': criteriaIds,
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
        data['password_confirmation'] = password;
      }

      await apiClient.dio.put(
        '${ApiConstants.juries}/$id',
        data: data,
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal memperbarui akun juri.'));
    }
  }

  Future<void> deleteJury(int id) async {
    try {
      await apiClient.dio.delete('${ApiConstants.juries}/$id');
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal menghapus akun juri.'));
    }
  }

  Future<void> toggleStatus(int id) async {
    try {
      await apiClient.dio.patch('${ApiConstants.juries}/$id/toggle-status');
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal mengubah status akun juri.'));
    }
  }
}