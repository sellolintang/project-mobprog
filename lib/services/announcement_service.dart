import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/announcement_readiness_model.dart';

class AnnouncementActionResult {
  final bool success;
  final String message;
  final AnnouncementReadinessModel? readiness;

  const AnnouncementActionResult({
    required this.success,
    required this.message,
    this.readiness,
  });
}

class AnnouncementService {
  final ApiClient apiClient;

  AnnouncementService({ApiClient? apiClient})
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

  Map<String, dynamic> _extractMap(dynamic responseData) {
    if (responseData is Map) {
      final data = responseData['data'];

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return Map<String, dynamic>.from(responseData);
    }

    return <String, dynamic>{};
  }

  String _extractMessage(dynamic responseData, String fallback) {
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }

    return fallback;
  }

  Future<AnnouncementReadinessModel> checkReadiness(int periodId) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.announcementCheckReadiness,
        data: {
          'period_id': periodId,
        },
      );

      final data = _extractMap(response.data);

      return AnnouncementReadinessModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal memeriksa kesiapan pengumuman.'),
      );
    }
  }

  Future<AnnouncementActionResult> publish({
    required int periodId,
    String? announcementNote,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.announcementPublish,
        data: {
          'period_id': periodId,
          if (announcementNote != null && announcementNote.trim().isNotEmpty)
            'announcement_note': announcementNote.trim(),
        },
      );

      final data = _extractMap(response.data);
      final readinessData = data['readiness'];

      return AnnouncementActionResult(
        success: true,
        message: _extractMessage(
          response.data,
          'Pengumuman berhasil dipublikasikan.',
        ),
        readiness: readinessData is Map
            ? AnnouncementReadinessModel.fromJson(
          Map<String, dynamic>.from(readinessData),
        )
            : null,
      );
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal mempublikasikan pengumuman.'),
      );
    }
  }

  Future<AnnouncementActionResult> unpublish(int periodId) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.announcementUnpublish,
        data: {
          'period_id': periodId,
        },
      );

      return AnnouncementActionResult(
        success: true,
        message: _extractMessage(
          response.data,
          'Publikasi pengumuman berhasil dibatalkan.',
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        _errorMessage(e, 'Gagal membatalkan publikasi pengumuman.'),
      );
    }
  }
}