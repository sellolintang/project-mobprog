import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/notifications/notification_service.dart';
import '../models/candidate_model.dart';
import 'candidate_service.dart';

class AdminNotificationCheckResult {
  final List<CandidateModel> allCandidates;
  final List<CandidateModel> pendingCandidates;
  final int pendingCount;
  final int newCandidateCount;
  final int newPendingCount;

  const AdminNotificationCheckResult({
    required this.allCandidates,
    required this.pendingCandidates,
    required this.pendingCount,
    required this.newCandidateCount,
    required this.newPendingCount,
  });
}

class AdminNotificationService {
  final CandidateService candidateService;

  AdminNotificationService({
    CandidateService? candidateService,
  }) : candidateService = candidateService ?? CandidateService();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _lastMaxCandidateIdKey = 'admin_last_max_candidate_id';
  static const String _lastPendingCountKey = 'admin_last_pending_count';

  Future<AdminNotificationCheckResult> checkCandidateNotifications({
    bool showLocalNotification = true,
  }) async {
    final candidates = await candidateService.getCandidates();

    final pendingCandidates = candidates
        .where((candidate) => candidate.status.toLowerCase() == 'pending')
        .toList();

    final int currentMaxCandidateId = candidates.fold<int>(
      0,
          (maxId, candidate) => candidate.id > maxId ? candidate.id : maxId,
    );

    final previousMaxCandidateIdRaw =
    await _storage.read(key: _lastMaxCandidateIdKey);
    final previousPendingCountRaw =
    await _storage.read(key: _lastPendingCountKey);

    final int? previousMaxCandidateId =
    int.tryParse(previousMaxCandidateIdRaw ?? '');
    final int previousPendingCount =
        int.tryParse(previousPendingCountRaw ?? '') ?? 0;

    final List<CandidateModel> newCandidates = previousMaxCandidateId == null
        ? <CandidateModel>[]
        : candidates
        .where((candidate) => candidate.id > previousMaxCandidateId)
        .toList();

    final List<CandidateModel> newPendingCandidates = newCandidates
        .where((candidate) => candidate.status.toLowerCase() == 'pending')
        .toList();

    if (showLocalNotification) {
      if (newPendingCandidates.isNotEmpty) {
        await NotificationService.showNotification(
          title: 'Calon Baru Mendaftar',
          body:
          '${newPendingCandidates.length} calon baru menunggu validasi admin.',
        );
      } else if (pendingCandidates.length > previousPendingCount) {
        await NotificationService.showNotification(
          title: 'Calon Pending Bertambah',
          body:
          'Ada ${pendingCandidates.length} calon pending yang perlu divalidasi.',
        );
      } else if (previousMaxCandidateId == null &&
          pendingCandidates.isNotEmpty) {
        await NotificationService.showNotification(
          title: 'Calon Pending Perlu Dicek',
          body:
          'Ada ${pendingCandidates.length} calon yang masih menunggu validasi.',
        );
      }
    }

    await _storage.write(
      key: _lastMaxCandidateIdKey,
      value: currentMaxCandidateId.toString(),
    );

    await _storage.write(
      key: _lastPendingCountKey,
      value: pendingCandidates.length.toString(),
    );

    return AdminNotificationCheckResult(
      allCandidates: candidates,
      pendingCandidates: pendingCandidates,
      pendingCount: pendingCandidates.length,
      newCandidateCount: newCandidates.length,
      newPendingCount: newPendingCandidates.length,
    );
  }
}