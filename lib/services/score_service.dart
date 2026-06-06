import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/score_model.dart';

class ScoreService {
  final ApiClient apiClient;

  ScoreService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return fallback;
  }

  Map<String, dynamic> _extractDataMap(dynamic responseData) {
    if (responseData is Map && responseData['data'] is Map) {
      return Map<String, dynamic>.from(responseData['data']);
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    return {};
  }

  Future<List<ScoreCandidateModel>> getScoringCandidates({
    required int periodId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.juryScoringCandidates,
        queryParameters: {
          'period_id': periodId,
        },
      );

      final data = _extractDataMap(response.data);
      final candidates = data['candidates'] is List ? data['candidates'] : [];

      return candidates
          .map(
            (item) => ScoreCandidateModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil data calon penilaian.'),
      );
    }
  }

  Future<List<ScoreCriterionModel>> getScoringForm({
    required int periodId,
    required int candidateId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiConstants.juryScoringCandidates}/$candidateId',
        queryParameters: {
          'period_id': periodId,
        },
      );

      final data = _extractDataMap(response.data);
      final criteria = data['criteria'] is List ? data['criteria'] : [];

      return criteria
          .map(
            (item) => ScoreCriterionModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil form penilaian.'),
      );
    }
  }

  Future<void> saveScores({
    required int periodId,
    required int candidateId,
    required List<Map<String, dynamic>> scores,
  }) async {
    try {
      await apiClient.dio.post(
        '${ApiConstants.juryScoringCandidates}/$candidateId/scores',
        data: {
          'period_id': periodId,
          'scores': scores,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal menyimpan nilai.'),
      );
    }
  }

  Future<List<ScoreCandidateModel>> getScoringHistory({
    required int periodId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.juryScoringHistory,
        queryParameters: {
          'period_id': periodId,
        },
      );

      final data = _extractDataMap(response.data);
      final histories = data['histories'] is List ? data['histories'] : [];

      return histories
          .map(
            (item) => ScoreCandidateModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil riwayat penilaian.'),
      );
    }
  }
}