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

  List _extractAdminResultList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }

    if (responseData is Map) {
      final data = responseData['data'];

      if (data is List) {
        return data;
      }

      if (data is Map && data['data'] is List) {
        return List.from(data['data']);
      }

      if (data is Map && data['items'] is List) {
        return List.from(data['items']);
      }
    }

    return [];
  }

  List _extractPublicResultList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }

    if (responseData is Map) {
      final data = responseData['data'];

      if (data is Map && data['results'] is List) {
        return List.from(data['results']);
      }

      if (data is List) {
        return data;
      }
    }

    return [];
  }

  Future<List<ArasResultModel>> getResults({int? periodId}) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.arasResults,
        queryParameters: {
          if (periodId != null) 'period_id': periodId,
        },
      );

      final data = _extractAdminResultList(response.data);

      return data
          .map(
            (item) => ArasResultModel.fromJson(
          Map<String, dynamic>.from(item as Map),
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
          if (periodId != null) 'period_id': periodId,
        },
      );

      final data = _extractPublicResultList(response.data);

      return data
          .map(
            (item) => ArasResultModel.fromJson(
          Map<String, dynamic>.from(item as Map),
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