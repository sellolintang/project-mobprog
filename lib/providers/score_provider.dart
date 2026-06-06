import 'package:flutter/material.dart';

import '../core/notifications/notification_service.dart';
import '../models/score_model.dart';
import '../services/score_service.dart';

class ScoreProvider extends ChangeNotifier {
  final ScoreService scoreService;

  ScoreProvider({ScoreService? scoreService})
      : scoreService = scoreService ?? ScoreService();

  List<ScoreCandidateModel> candidates = [];
  List<ScoreCandidateModel> histories = [];
  List<ScoreCriterionModel> criteria = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchCandidates({required int periodId}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      candidates = await scoreService.getScoringCandidates(
        periodId: periodId,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> fetchScoringForm({
    required int periodId,
    required int candidateId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      criteria = await scoreService.getScoringForm(
        periodId: periodId,
        candidateId: candidateId,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> saveScores({
    required int periodId,
    required int candidateId,
    required String candidateName,
    required List<Map<String, dynamic>> scores,
  }) async {
    try {
      await scoreService.saveScores(
        periodId: periodId,
        candidateId: candidateId,
        scores: scores,
      );

      await NotificationService.showNotification(
        title: 'Nilai Berhasil Disimpan',
        body: 'Nilai untuk $candidateName berhasil disimpan.',
      );

      await fetchCandidates(periodId: periodId);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchHistory({required int periodId}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      histories = await scoreService.getScoringHistory(
        periodId: periodId,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void clearForm() {
    criteria = [];
    errorMessage = null;
    notifyListeners();
  }
}