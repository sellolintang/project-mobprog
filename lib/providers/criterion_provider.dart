import 'package:flutter/material.dart';

import '../core/notifications/notification_service.dart';
import '../models/criterion_model.dart';
import '../services/criterion_service.dart';

class CriterionProvider extends ChangeNotifier {
  final CriterionService criterionService;

  CriterionProvider({CriterionService? criterionService})
      : criterionService = criterionService ?? CriterionService();

  List<CriterionModel> criteria = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchCriteria() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      criteria = await criterionService.getCriteria();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createCriterion({
    required int periodId,
    required String code,
    required String name,
    required double weight,
    required String type,
    required double minScore,
    required double maxScore,
    required bool isActive,
  }) async {
    try {
      await criterionService.createCriterion(
        periodId: periodId,
        code: code,
        name: name,
        weight: weight,
        type: type,
        minScore: minScore,
        maxScore: maxScore,
        isActive: isActive,
      );

      await NotificationService.showNotification(
        title: 'Kriteria Ditambahkan',
        body: 'Kriteria $name berhasil ditambahkan.',
      );

      await fetchCriteria();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCriterion({
    required int id,
    required int periodId,
    required String code,
    required String name,
    required double weight,
    required String type,
    required double minScore,
    required double maxScore,
    required bool isActive,
  }) async {
    try {
      await criterionService.updateCriterion(
        id: id,
        periodId: periodId,
        code: code,
        name: name,
        weight: weight,
        type: type,
        minScore: minScore,
        maxScore: maxScore,
        isActive: isActive,
      );

      await NotificationService.showNotification(
        title: 'Kriteria Diperbarui',
        body: 'Kriteria $name berhasil diperbarui.',
      );

      await fetchCriteria();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCriterion(int id) async {
    try {
      await criterionService.deleteCriterion(id);

      await NotificationService.showNotification(
        title: 'Kriteria Dihapus',
        body: 'Data kriteria berhasil dihapus.',
      );

      await fetchCriteria();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}