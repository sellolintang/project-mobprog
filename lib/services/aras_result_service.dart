import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/aras_result_model.dart';

class ArasResultService {
  final ApiClient apiClient;

  ArasResultService({ApiClient? apiClient})
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

  Future<List<ArasResultModel>> getResults({int? periodId}) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.arasResults,
        queryParameters: {
          'period_id': ?periodId,
        },
      );

      final data = _extractList(response.data);

      return data
          .map(
            (item) => ArasResultModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal mengambil hasil ARAS.'));
    }
  }

  Future<void> calculateResults(int periodId) async {
    try {
      await apiClient.dio.post(
        ApiConstants.calculateAras,
        data: {
          'period_id': periodId,
        },
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal menghitung hasil ARAS.'));
    }
  }

  Future<void> deleteResult(int id) async {
    try {
      await apiClient.dio.delete('${ApiConstants.arasResults}/$id');
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal menghapus hasil ARAS.'));
    }
  }

  Future<List<ArasResultModel>> getPublicResults({int? periodId}) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.publicResults,
        queryParameters: {
          'period_id': ?periodId,
        },
      );

      final data = _extractList(response.data);

      return data
          .map(
            (item) => ArasResultModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil hasil pemilihan publik.'),
      );
    }
  }
}