import 'package:flutter/material.dart';

import '../core/notifications/notification_service.dart';
import '../models/jury_model.dart';
import '../services/jury_service.dart';

class JuryProvider extends ChangeNotifier {
  final JuryService juryService;

  JuryProvider({JuryService? juryService})
      : juryService = juryService ?? JuryService();

  List<JuryModel> juries = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchJuries({
    int? periodId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      juries = await juryService.getJuries(
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

  Future<bool> createJury({
    required int periodId,
    required String name,
    required String email,
    required String phone,
    required String password,
    required bool isActive,
    required List<int> criteriaIds,
  }) async {
    try {
      await juryService.createJury(
        periodId: periodId,
        name: name,
        email: email,
        phone: phone,
        password: password,
        isActive: isActive,
        criteriaIds: criteriaIds,
      );

      await NotificationService.showNotification(
        title: 'Juri Ditambahkan',
        body: 'Akun juri $name berhasil ditambahkan.',
      );

      await fetchJuries(periodId: periodId);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateJury({
    required int id,
    required int periodId,
    required String name,
    required String email,
    required String phone,
    String? password,
    required bool isActive,
    required List<int> criteriaIds,
  }) async {
    try {
      await juryService.updateJury(
        id: id,
        periodId: periodId,
        name: name,
        email: email,
        phone: phone,
        password: password,
        isActive: isActive,
        criteriaIds: criteriaIds,
      );

      await NotificationService.showNotification(
        title: 'Juri Diperbarui',
        body: 'Akun juri $name berhasil diperbarui.',
      );

      await fetchJuries(periodId: periodId);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteJury(int id) async {
    try {
      await juryService.deleteJury(id);

      await NotificationService.showNotification(
        title: 'Juri Dihapus',
        body: 'Data akun juri berhasil dihapus atau dinonaktifkan.',
      );

      await fetchJuries();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleStatus(int id) async {
    try {
      await juryService.toggleStatus(id);
      await fetchJuries();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}