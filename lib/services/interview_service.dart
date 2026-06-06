import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/interview_model.dart';

class InterviewService {
  final ApiClient apiClient;

  InterviewService({ApiClient? apiClient})
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

  Future<List<InterviewModel>> getInterviews() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.interviews);
      final data = _extractList(response.data);

      return data
          .map(
            (item) => InterviewModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal mengambil jadwal wawancara.'));
    }
  }

  Future<void> createInterview({
    required int candidateId,
    required String scheduledAt,
    String? location,
    required String status,
  }) async {
    try {
      await apiClient.dio.post(
        ApiConstants.interviews,
        data: {
          'candidate_id': candidateId,
          'scheduled_at': scheduledAt,
          'location': location,
          'status': status,
        },
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal menambahkan jadwal wawancara.'));
    }
  }

  Future<void> updateInterview({
    required int id,
    required int candidateId,
    required String scheduledAt,
    String? location,
    required String status,
  }) async {
    try {
      await apiClient.dio.put(
        '${ApiConstants.interviews}/$id',
        data: {
          'candidate_id': candidateId,
          'scheduled_at': scheduledAt,
          'location': location,
          'status': status,
        },
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal memperbarui jadwal wawancara.'));
    }
  }

  Future<void> deleteInterview(int id) async {
    try {
      await apiClient.dio.delete('${ApiConstants.interviews}/$id');
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal menghapus jadwal wawancara.'));
    }
  }

  Future<void> generateInterviews({
    required int periodId,
    required String interviewDate,
    required String startTime,
    required int durationMinutes,
    String? location,
  }) async {
    try {
      await apiClient.dio.post(
        ApiConstants.generateInterviews,
        data: {
          'period_id': periodId,
          'interview_date': interviewDate,
          'start_time': startTime,
          'duration_minutes': durationMinutes,
          'location': location,
        },
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal membuat jadwal otomatis.'));
    }
  }

  Future<void> resetInterviews(int periodId) async {
    try {
      await apiClient.dio.post(
        ApiConstants.resetInterviews,
        data: {
          'period_id': periodId,
        },
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Gagal reset jadwal wawancara.'));
    }
  }
}