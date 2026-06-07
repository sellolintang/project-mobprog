import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/jury_dashboard_model.dart';

class JuryDashboardService {
  final ApiClient apiClient;

  JuryDashboardService({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map) {
      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['errors'] != null) {
        return data['errors'].toString();
      }
    }

    return fallback;
  }

  Future<JuryDashboardModel> getSummary({
    required int periodId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.juryDashboardSummary,
        queryParameters: {
          'period_id': periodId,
        },
      );

      final responseData = response.data;

      if (responseData is Map && responseData['data'] is Map) {
        return JuryDashboardModel.fromJson(
          Map<String, dynamic>.from(responseData['data'] as Map),
        );
      }

      throw Exception('Format data dashboard juri tidak valid.');
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil dashboard juri.'),
      );
    }
  }
}