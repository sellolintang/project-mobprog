import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/period_model.dart';

class PeriodService {
  final ApiClient apiClient;

  PeriodService({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return fallback;
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }

    if (responseData is Map) {
      final data = responseData['data'];

      if (data is List) {
        return data;
      }

      if (data is Map && data['data'] is List) {
        return List<dynamic>.from(data['data']);
      }

      if (data is Map && data['items'] is List) {
        return List<dynamic>.from(data['items']);
      }
    }

    return [];
  }

  Future<List<PeriodModel>> getPeriods() async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.periods,
        queryParameters: {
          'per_page': 100,
        },
      );

      final data = _extractList(response.data);

      return data
          .map(
            (item) => PeriodModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil data periode.'),
      );
    }
  }

  Future<void> createPeriod({
    required int electionYear,
    required String status,
    String? registrationStart,
    String? registrationEnd,
    String? interviewStart,
    String? interviewEnd,
  }) async {
    try {
      await apiClient.dio.post(
        ApiConstants.periods,
        data: {
          'election_year': electionYear,
          'status': status,
          'registration_start': registrationStart,
          'registration_end': registrationEnd,
          'interview_start': interviewStart,
          'interview_end': interviewEnd,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal menambahkan periode.'),
      );
    }
  }

  Future<void> updatePeriod({
    required int id,
    required int electionYear,
    required String status,
    String? registrationStart,
    String? registrationEnd,
    String? interviewStart,
    String? interviewEnd,
  }) async {
    try {
      await apiClient.dio.put(
        '${ApiConstants.periods}/$id',
        data: {
          'election_year': electionYear,
          'status': status,
          'registration_start': registrationStart,
          'registration_end': registrationEnd,
          'interview_start': interviewStart,
          'interview_end': interviewEnd,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengubah periode.'),
      );
    }
  }

  Future<void> deletePeriod(int id) async {
    try {
      await apiClient.dio.delete('${ApiConstants.periods}/$id');
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal menghapus periode.'),
      );
    }
  }
}