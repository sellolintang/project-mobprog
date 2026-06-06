import 'package:flutter/material.dart';

import '../core/notifications/notification_service.dart';
import '../models/period_model.dart';
import '../services/period_service.dart';

class PeriodProvider extends ChangeNotifier {
  final PeriodService periodService;

  PeriodProvider({PeriodService? periodService})
      : periodService = periodService ?? PeriodService();

  List<PeriodModel> periods = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchPeriods() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      periods = await periodService.getPeriods();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createPeriod({
    required int electionYear,
    required String status,
  }) async {
    try {
      await periodService.createPeriod(
        electionYear: electionYear,
        status: status,
      );

      await NotificationService.showNotification(
        title: 'Periode Ditambahkan',
        body: 'Periode pemilihan $electionYear berhasil ditambahkan.',
      );

      await fetchPeriods();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePeriod({
    required int id,
    required int electionYear,
    required String status,
  }) async {
    try {
      await periodService.updatePeriod(
        id: id,
        electionYear: electionYear,
        status: status,
      );

      await NotificationService.showNotification(
        title: 'Periode Diperbarui',
        body: 'Data periode $electionYear berhasil diperbarui.',
      );

      await fetchPeriods();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePeriod(int id) async {
    try {
      await periodService.deletePeriod(id);

      await NotificationService.showNotification(
        title: 'Periode Dihapus',
        body: 'Data periode berhasil dihapus.',
      );

      await fetchPeriods();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}