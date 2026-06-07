import 'package:flutter/material.dart';

import '../core/notifications/notification_service.dart';
import '../models/aras_result_model.dart';
import '../services/aras_result_service.dart';

class ArasResultProvider extends ChangeNotifier {
  final ArasResultService arasResultService;

  ArasResultProvider({ArasResultService? arasResultService})
      : arasResultService = arasResultService ?? ArasResultService();

  List<ArasResultModel> results = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchResults({int? periodId}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      results = await arasResultService.getResults(periodId: periodId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> calculateResults(int periodId) async {
    try {
      await arasResultService.calculateResults(periodId);

      await NotificationService.showNotification(
        title: 'Perhitungan ARAS Berhasil',
        body: 'Ranking calon Duta Kampus berhasil dihitung.',
      );

      await fetchResults(periodId: periodId);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteResult(int id, {int? periodId}) async {
    try {
      await arasResultService.deleteResult(id);
      await fetchResults(periodId: periodId);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchPublicResults({int? periodId}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      results = await arasResultService.getPublicResults(
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
}