import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/criterion_model.dart';

class CriterionService {
  final ApiClient apiClient;

  CriterionService({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

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
        responseData['data']['items'] is List) {
      return responseData['data']['items'];
    }

    return [];
  }

  Future<List<CriterionModel>> getCriteria() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.criteria);
      final data = _extractList(response.data);

      return data
          .map(
            (item) => CriterionModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal mengambil data kriteria.'));
    }
  }

  Future<void> createCriterion({
    required int periodId,
    required String code,
    required String name,
    required double weight,
    required String type,
    required double minScore,
    required double maxScore,
    required bool isActive,
  }) async {
    try {
      await apiClient.dio.post(
        ApiConstants.criteria,
        data: {
          'period_id': periodId,
          'code': code,
          'name': name,
          'weight': weight,
          'type': type,
          'min_score': minScore,
          'max_score': maxScore,
          'is_active': isActive,
        },
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal menambahkan kriteria.'));
    }
  }

  Future<void> updateCriterion({
    required int id,
    required int periodId,
    required String code,
    required String name,
    required double weight,
    required String type,
    required double minScore,
    required double maxScore,
    required bool isActive,
  }) async {
    try {
      await apiClient.dio.put(
        '${ApiConstants.criteria}/$id',
        data: {
          'period_id': periodId,
          'code': code,
          'name': name,
          'weight': weight,
          'type': type,
          'min_score': minScore,
          'max_score': maxScore,
          'is_active': isActive,
        },
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal mengubah kriteria.'));
    }
  }

  Future<void> deleteCriterion(int id) async {
    try {
      await apiClient.dio.delete('${ApiConstants.criteria}/$id');
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal menghapus kriteria.'));
    }
  }
}