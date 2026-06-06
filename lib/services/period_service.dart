import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/period_model.dart';

class PeriodService {
  final ApiClient apiClient;

  PeriodService({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<List<PeriodModel>> getPeriods() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.periods);

      final responseData = response.data;

      List data;

      if (responseData is List) {
        data = responseData;
      } else if (responseData['data'] is List) {
        data = responseData['data'];
      } else if (responseData['data']?['items'] is List) {
        data = responseData['data']['items'];
      } else {
        data = [];
      }

      return data.map((item) => PeriodModel.fromJson(item)).toList();
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Gagal mengambil data periode.';
      throw Exception(message);
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
      final message = e.response?.data['message'] ?? 'Gagal menambahkan periode.';
      throw Exception(message);
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
      final message = e.response?.data['message'] ?? 'Gagal mengubah periode.';
      throw Exception(message);
    }
  }

  Future<void> deletePeriod(int id) async {
    try {
      await apiClient.dio.delete('${ApiConstants.periods}/$id');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Gagal menghapus periode.';
      throw Exception(message);
    }
  }
}