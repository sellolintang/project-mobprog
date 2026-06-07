import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/candidate_model.dart';

class CandidateService {
  final ApiClient apiClient;

  CandidateService({ApiClient? apiClient})
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

  Future<List<CandidateModel>> getCandidates() async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.candidates,
        queryParameters: {
          'per_page': 100,
        },
      );

      final data = _extractList(response.data);

      return data
          .map(
            (item) => CandidateModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mengambil data calon.'),
      );
    }
  }

  Future<void> validateCandidate(int id) async {
    try {
      await apiClient.dio.patch(
        '${ApiConstants.candidates}/$id/validate',
      );
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal memvalidasi calon.'),
      );
    }
  }

  Future<void> rejectCandidate({
    required int id,
    required String rejectionReason,
  }) async {
    try {
      await apiClient.dio.patch(
        '${ApiConstants.candidates}/$id/reject',
        data: {
          'rejection_reason': rejectionReason,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal menolak calon.'),
      );
    }
  }

  Future<void> deleteCandidate(int id) async {
    try {
      await apiClient.dio.delete('${ApiConstants.candidates}/$id');
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal menghapus calon.'),
      );
    }
  }
}