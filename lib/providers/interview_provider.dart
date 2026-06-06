import 'package:flutter/material.dart';

import '../core/notifications/notification_service.dart';
import '../models/interview_model.dart';
import '../services/interview_service.dart';

class InterviewProvider extends ChangeNotifier {
  final InterviewService interviewService;

  InterviewProvider({InterviewService? interviewService})
      : interviewService = interviewService ?? InterviewService();

  List<InterviewModel> interviews = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchInterviews() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      interviews = await interviewService.getInterviews();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> createInterview({
    required int candidateId,
    required String scheduledAt,
    String? location,
    required String status,
  }) async {
    try {
      await interviewService.createInterview(
        candidateId: candidateId,
        scheduledAt: scheduledAt,
        location: location,
        status: status,
      );

      await NotificationService.showNotification(
        title: 'Jadwal Ditambahkan',
        body: 'Jadwal wawancara berhasil ditambahkan.',
      );

      await fetchInterviews();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateInterview({
    required int id,
    required int candidateId,
    required String scheduledAt,
    String? location,
    required String status,
  }) async {
    try {
      await interviewService.updateInterview(
        id: id,
        candidateId: candidateId,
        scheduledAt: scheduledAt,
        location: location,
        status: status,
      );

      await NotificationService.showNotification(
        title: 'Jadwal Diperbarui',
        body: 'Jadwal wawancara berhasil diperbarui.',
      );

      await fetchInterviews();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteInterview(int id) async {
    try {
      await interviewService.deleteInterview(id);

      await NotificationService.showNotification(
        title: 'Jadwal Dihapus',
        body: 'Jadwal wawancara berhasil dihapus.',
      );

      await fetchInterviews();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> generateInterviews({
    required int periodId,
    required String interviewDate,
    required String startTime,
    required int durationMinutes,
    String? location,
  }) async {
    try {
      await interviewService.generateInterviews(
        periodId: periodId,
        interviewDate: interviewDate,
        startTime: startTime,
        durationMinutes: durationMinutes,
        location: location,
      );

      await NotificationService.showNotification(
        title: 'Jadwal Otomatis Dibuat',
        body: 'Jadwal wawancara berhasil dibuat otomatis.',
      );

      await fetchInterviews();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetInterviews(int periodId) async {
    try {
      await interviewService.resetInterviews(periodId);

      await NotificationService.showNotification(
        title: 'Jadwal Direset',
        body: 'Jadwal wawancara berhasil direset.',
      );

      await fetchInterviews();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}