import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/score_model.dart';

class ScoreService {
  final ApiClient apiClient;

  ScoreService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

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

  Map<String, dynamic> _extractDataMap(dynamic responseData) {
    if (responseData is Map && responseData['data'] is Map) {
      return Map<String, dynamic>.from(responseData['data'] as Map);
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _extractMapList(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
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
      final candidateList = _extractMapList(data['candidates']);

      return candidateList
          .map((item) => ScoreCandidateModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil data calon penilaian.'),
      );
    }
  }

  Future<ScoringFormDataModel> getScoringForm({
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

      return ScoringFormDataModel.fromJson(data);
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
      final historyList = _extractMapList(data['histories']);

      return historyList
          .map((item) => ScoreCandidateModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil riwayat penilaian.'),
      );
    }
  }

  Future<ScoringHistoryDetailModel> getScoringHistoryDetail({
    required int periodId,
    required int candidateId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiConstants.juryScoringHistory}/$candidateId',
        queryParameters: {
          'period_id': periodId,
        },
      );

      final data = _extractDataMap(response.data);

      return ScoringHistoryDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil detail riwayat penilaian.'),
      );
    }
  }
}