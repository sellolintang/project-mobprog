import 'package:flutter/material.dart';

import '../core/notifications/notification_service.dart';
import '../models/candidate_action_result.dart';
import '../models/candidate_model.dart';
import '../services/candidate_service.dart';

class CandidateProvider extends ChangeNotifier {
  final CandidateService candidateService;

  CandidateProvider({CandidateService? candidateService})
      : candidateService = candidateService ?? CandidateService();

  List<CandidateModel> candidates = [];
  bool isLoading = false;
  String? errorMessage;
  CandidateActionResult? lastActionResult;

  Future<void> fetchCandidates() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      candidates = await candidateService.getCandidates();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> validateCandidate(int id, String candidateName) async {
    try {
      errorMessage = null;
      lastActionResult = null;
      notifyListeners();

      final result = await candidateService.validateCandidate(id);
      lastActionResult = result;

      await NotificationService.showNotification(
        title: 'Calon Diterima',
        body: result.emailSent
            ? '$candidateName berhasil diterima dan email penerimaan sudah dikirim.'
            : '$candidateName berhasil diterima, tetapi email gagal dikirim.',
      );

      await fetchCandidates();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectCandidate({
    required int id,
    required String candidateName,
    required String rejectionReason,
  }) async {
    try {
      errorMessage = null;
      lastActionResult = null;
      notifyListeners();

      final result = await candidateService.rejectCandidate(
        id: id,
        rejectionReason: rejectionReason,
      );

      lastActionResult = result;

      await NotificationService.showNotification(
        title: 'Calon Ditolak',
        body: result.emailSent
            ? '$candidateName berhasil ditolak dan email penolakan sudah dikirim.'
            : '$candidateName berhasil ditolak, tetapi email gagal dikirim.',
      );

      await fetchCandidates();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCandidate(int id) async {
    try {
      errorMessage = null;
      await candidateService.deleteCandidate(id);

      await NotificationService.showNotification(
        title: 'Calon Dihapus',
        body: 'Data calon berhasil dihapus.',
      );

      await fetchCandidates();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}