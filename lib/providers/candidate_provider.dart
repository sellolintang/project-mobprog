import 'package:flutter/material.dart';

import '../core/notifications/notification_service.dart';
import '../models/candidate_model.dart';
import '../services/candidate_service.dart';

class CandidateProvider extends ChangeNotifier {
  final CandidateService candidateService;

  CandidateProvider({CandidateService? candidateService})
      : candidateService = candidateService ?? CandidateService();

  List<CandidateModel> candidates = [];
  bool isLoading = false;
  String? errorMessage;

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
      await candidateService.validateCandidate(id);

      await NotificationService.showNotification(
        title: 'Calon Divalidasi',
        body: '$candidateName berhasil divalidasi.',
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
      await candidateService.rejectCandidate(
        id: id,
        rejectionReason: rejectionReason,
      );

      await NotificationService.showNotification(
        title: 'Calon Ditolak',
        body: '$candidateName berhasil ditolak.',
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