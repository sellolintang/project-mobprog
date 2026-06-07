import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/score_monitoring_model.dart';

class MonitoringService {
  final ApiClient apiClient;

  MonitoringService({ApiClient? apiClient})
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

  Future<ScoreMonitoringModel> getScoreMonitoring({
    required int periodId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.monitoringScores,
        queryParameters: {
          'period_id': periodId,
        },
      );

      final responseData = response.data;

      if (responseData is Map && responseData['data'] is Map) {
        return ScoreMonitoringModel.fromJson(
          Map<String, dynamic>.from(responseData['data'] as Map),
        );
      }

      throw Exception('Format data monitoring tidak valid.');
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil data monitoring nilai.'),
      );
    }
  }
}