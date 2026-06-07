import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/candidate_model.dart';
import '../../models/criterion_model.dart';
import '../../models/jury_model.dart';
import '../../models/period_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_notification_service.dart';
import '../../services/candidate_service.dart';
import '../../services/criterion_service.dart';
import '../../services/jury_service.dart';
import '../../services/period_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminNotificationService _adminNotificationService =
  AdminNotificationService();

  final CandidateService _candidateService = CandidateService();
  final JuryService _juryService = JuryService();
  final CriterionService _criterionService = CriterionService();
  final PeriodService _periodService = PeriodService();

  Timer? _notificationTimer;

  bool _isCheckingNotification = false;
  bool _isLoadingDashboard = false;

  String? _notificationError;
  String? _dashboardError;

  int _pendingCandidateCount = 0;
  int _newCandidateCount = 0;
  int _newPendingCandidateCount = 0;

  _DashboardStats _stats = _DashboardStats.empty();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDashboardData();
    });

    _notificationTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        if (!mounted) return;
        _checkAdminNotifications();
      },
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  PeriodModel? _selectMainPeriod(List<PeriodModel> periods) {
    if (periods.isEmpty) return null;

    final sortedPeriods = List<PeriodModel>.from(periods)
      ..sort((a, b) => b.electionYear.compareTo(a.electionYear));

    PeriodModel? findByStatus(String status) {
      try {
        return sortedPeriods.firstWhere(
              (period) => period.status.toLowerCase() == status,
        );
      } catch (_) {
        return null;
      }
    }

    return findByStatus('registration') ??
        findByStatus('interview') ??
        findByStatus('scoring') ??
        findByStatus('draft') ??
        sortedPeriods.first;
  }

  int _countCandidateStatus(
      List<CandidateModel> candidates,
      String status,
      ) {
    return candidates
        .where((candidate) => candidate.status.toLowerCase() == status)
        .length;
  }

  _DashboardStats _buildStats({
    required List<CandidateModel> candidates,
    required List<JuryModel> juries,
    required List<CriterionModel> criteria,
    required List<PeriodModel> periods,
  }) {
    final mainPeriod = _selectMainPeriod(periods);

    final candidatesInPeriod = mainPeriod == null
        ? candidates
        : candidates
        .where((candidate) => candidate.periodId == mainPeriod.id)
        .toList();

    final criteriaInPeriod = mainPeriod == null
        ? criteria
        : criteria.where((criterion) => criterion.periodId == mainPeriod.id).toList();

    return _DashboardStats(
      mainPeriod: mainPeriod,
      totalPeriods: periods.length,
      totalCandidates: candidatesInPeriod.length,
      pendingCandidates: _countCandidateStatus(candidatesInPeriod, 'pending'),
      validCandidates: _countCandidateStatus(candidatesInPeriod, 'valid'),
      invalidCandidates: _countCandidateStatus(candidatesInPeriod, 'invalid'),
      scheduledCandidates: _countCandidateStatus(
        candidatesInPeriod,
        'interview_scheduled',
      ),
      interviewedCandidates: _countCandidateStatus(
        candidatesInPeriod,
        'interviewed',
      ),
      scoredCandidates: _countCandidateStatus(candidatesInPeriod, 'scored'),
      totalJuries: juries.length,
      activeJuries: juries.where((jury) => jury.isActive).length,
      totalCriteria: criteriaInPeriod.length,
      activeCriteria:
      criteriaInPeriod.where((criterion) => criterion.isActive).length,
    );
  }

  Future<void> _loadDashboardData({
    bool showLocalNotification = true,
  }) async {
    try {
      setState(() {
        _isLoadingDashboard = true;
        _dashboardError = null;
        _notificationError = null;
      });

      final notificationResult =
      await _adminNotificationService.checkCandidateNotifications(
        showLocalNotification: showLocalNotification,
      );

      final periods = await _periodService.getPeriods();
      final mainPeriod = _selectMainPeriod(periods);

      final juries = await _juryService.getJuries(
        periodId: mainPeriod?.id,
      );

      final criteria = await _criterionService.getCriteria();

      final stats = _buildStats(
        candidates: notificationResult.allCandidates,
        juries: juries,
        criteria: criteria,
        periods: periods,
      );

      if (!mounted) return;

      setState(() {
        _pendingCandidateCount = notificationResult.pendingCount;
        _newCandidateCount = notificationResult.newCandidateCount;
        _newPendingCandidateCount = notificationResult.newPendingCount;
        _stats = stats;
        _isLoadingDashboard = false;
        _isCheckingNotification = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingDashboard = false;
        _isCheckingNotification = false;
        _dashboardError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _checkAdminNotifications({
    bool showLocalNotification = true,
  }) async {
    try {
      setState(() {
        _isCheckingNotification = true;
        _notificationError = null;
      });

      final result =
      await _adminNotificationService.checkCandidateNotifications(
        showLocalNotification: showLocalNotification,
      );

      final updatedStats = _stats.copyWithCandidateData(
        allCandidates: result.allCandidates,
        mainPeriod: _stats.mainPeriod,
      );

      if (!mounted) return;

      setState(() {
        _pendingCandidateCount = result.pendingCount;
        _newCandidateCount = result.newCandidateCount;
        _newPendingCandidateCount = result.newPendingCount;
        _stats = updatedStats;
        _isCheckingNotification = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCheckingNotification = false;
        _notificationError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.publicHome,
          (route) => false,
    );
  }

  Future<void> _openCandidateList() async {
    await Navigator.pushNamed(context, AppRoutes.candidateList);

    if (!mounted) return;

    await _loadDashboardData(showLocalNotification: false);
  }

  Future<void> _openRouteAndRefresh(String routeName) async {
    await Navigator.pushNamed(context, routeName);

    if (!mounted) return;

    await _loadDashboardData(showLocalNotification: false);
  }

  String _periodStatusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'registration':
        return 'Pendaftaran';
      case 'interview':
        return 'Wawancara';
      case 'scoring':
        return 'Penilaian';
      case 'finished':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _periodStatusColor(String status) {
    switch (status) {
      case 'registration':
        return Colors.green;
      case 'interview':
        return Colors.blue;
      case 'scoring':
        return Colors.purple;
      case 'finished':
        return Colors.grey;
      case 'draft':
      default:
        return Colors.orange;
    }
  }

  Widget _dashboardErrorCard() {
    if (_dashboardError == null) return const SizedBox.shrink();

    return Card(
      color: const Color(0xFFFEF2F2),
      child: ListTile(
        leading: const Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
        title: const Text(
          'Gagal Memuat Statistik Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_dashboardError!),
        trailing: IconButton(
          onPressed: () => _loadDashboardData(showLocalNotification: false),
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _periodSummaryCard() {
    final period = _stats.mainPeriod;

    if (_isLoadingDashboard && period == null) {
      return const Card(
        child: ListTile(
          leading: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('Memuat periode aktif...'),
          subtitle: Text('Sistem sedang mengambil data periode.'),
        ),
      );
    }

    if (period == null) {
      return Card(
        color: const Color(0xFFFFFBEB),
        child: ListTile(
          leading: const Icon(
            Icons.event_busy,
            color: Colors.orange,
          ),
          title: const Text(
            'Belum Ada Periode',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Silakan buat periode pemilihan terlebih dahulu.',
          ),
          trailing: FilledButton(
            onPressed: () => _openRouteAndRefresh(AppRoutes.periodList),
            child: const Text('Kelola'),
          ),
        ),
      );
    }

    final color = _periodStatusColor(period.status);

    return Card(
      color: const Color(0xFFEFF6FF),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.16),
              child: Icon(Icons.event_available, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Periode Duta Kampus ${period.electionYear}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          _periodStatusLabel(period.status),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: color,
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text('${_stats.totalPeriods} periode tersimpan'),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if ((period.registrationStart ?? '').isNotEmpty)
                    Text('Pendaftaran mulai: ${period.registrationStart}'),
                  if ((period.registrationEnd ?? '').isNotEmpty)
                    Text('Pendaftaran berakhir: ${period.registrationEnd}'),
                  if ((period.interviewStart ?? '').isNotEmpty)
                    Text('Wawancara mulai: ${period.interviewStart}'),
                  if ((period.interviewEnd ?? '').isNotEmpty)
                    Text('Wawancara berakhir: ${period.interviewEnd}'),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Kelola periode',
              onPressed: () => _openRouteAndRefresh(AppRoutes.periodList),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsSection() {
    if (_isLoadingDashboard && _stats.totalCandidates == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Memuat statistik dashboard...'),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final int columns = width >= 900
            ? 4
            : width >= 620
            ? 3
            : width >= 430
            ? 2
            : 1;

        final double spacing = 12;
        final double cardWidth = columns == 1
            ? width
            : (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _StatCard(
              width: cardWidth,
              icon: Icons.people_alt,
              title: 'Total Calon',
              value: _stats.totalCandidates.toString(),
              subtitle: 'Pada periode utama',
              color: Colors.blue,
              onTap: _openCandidateList,
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.hourglass_top,
              title: 'Pending',
              value: _stats.pendingCandidates.toString(),
              subtitle: 'Menunggu validasi',
              color: Colors.orange,
              onTap: _openCandidateList,
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.verified,
              title: 'Valid',
              value: _stats.validCandidates.toString(),
              subtitle: 'Sudah diterima',
              color: Colors.green,
              onTap: _openCandidateList,
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.cancel,
              title: 'Ditolak',
              value: _stats.invalidCandidates.toString(),
              subtitle: 'Tidak lolos validasi',
              color: Colors.red,
              onTap: _openCandidateList,
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.event_available,
              title: 'Dijadwalkan',
              value: _stats.scheduledCandidates.toString(),
              subtitle: 'Wawancara terjadwal',
              color: Colors.indigo,
              onTap: () => _openRouteAndRefresh(AppRoutes.interviewList),
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.record_voice_over,
              title: 'Wawancara',
              value: _stats.interviewedCandidates.toString(),
              subtitle: 'Sudah wawancara',
              color: Colors.purple,
              onTap: _openCandidateList,
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.star_rate,
              title: 'Sudah Dinilai',
              value: _stats.scoredCandidates.toString(),
              subtitle: 'Siap masuk hasil',
              color: Colors.teal,
              onTap: () => _openRouteAndRefresh(AppRoutes.arasResultList),
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.groups,
              title: 'Juri Aktif',
              value: '${_stats.activeJuries}/${_stats.totalJuries}',
              subtitle: 'Akun penilai',
              color: Colors.cyan,
              onTap: () => _openRouteAndRefresh(AppRoutes.juryList),
            ),
            _StatCard(
              width: cardWidth,
              icon: Icons.rule,
              title: 'Kriteria Aktif',
              value: '${_stats.activeCriteria}/${_stats.totalCriteria}',
              subtitle: 'Kriteria periode utama',
              color: Colors.deepOrange,
              onTap: () => _openRouteAndRefresh(AppRoutes.criterionList),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard Admin'),
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifikasi calon pending',
                onPressed: _openCandidateList,
                icon: const Icon(Icons.notifications_outlined),
              ),
              if (_pendingCandidateCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      _pendingCandidateCount > 99
                          ? '99+'
                          : _pendingCandidateCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: _isLoadingDashboard
                ? null
                : () => _loadDashboardData(showLocalNotification: false),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadDashboardData(showLocalNotification: false),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.admin_panel_settings),
                ),
                title: Text(user?.name ?? 'Admin'),
                subtitle: Text(user?.email ?? '-'),
              ),
            ),

            const SizedBox(height: 16),

            _dashboardErrorCard(),

            if (_dashboardError != null) const SizedBox(height: 16),

            _AdminNotificationCard(
              pendingCandidateCount: _pendingCandidateCount,
              newCandidateCount: _newCandidateCount,
              newPendingCandidateCount: _newPendingCandidateCount,
              isLoading: _isCheckingNotification,
              errorMessage: _notificationError,
              onRefresh: () => _checkAdminNotifications(),
              onOpenCandidates: _openCandidateList,
            ),

            const SizedBox(height: 16),

            // const Text(
            //   'Ringkasan Periode',
            //   style: TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            //
            // const SizedBox(height: 12),
            //
            // _periodSummaryCard(),
            //
            // const SizedBox(height: 16),

            const Text(
              'Statistik Admin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _statsSection(),

            const SizedBox(height: 24),

            const Text(
              'Menu Admin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _AdminMenuCard(
              icon: Icons.event_note,
              title: 'Periode Pemilihan',
              subtitle: 'Kelola tahun, status, dan jadwal periode',
              onTap: () => _openRouteAndRefresh(AppRoutes.periodList),
            ),
            _AdminMenuCard(
              icon: Icons.people_alt,
              title: 'Data Calon',
              subtitle: 'Lihat, validasi, atau tolak calon',
              onTap: _openCandidateList,
            ),
            _AdminMenuCard(
              icon: Icons.rule,
              title: 'Kriteria Penilaian',
              subtitle: 'Kelola kriteria dan bobot ARAS',
              onTap: () => _openRouteAndRefresh(AppRoutes.criterionList),
            ),
            _AdminMenuCard(
              icon: Icons.groups,
              title: 'Data Juri',
              subtitle: 'Kelola akun juri dan pembagian kriteria',
              onTap: () => _openRouteAndRefresh(AppRoutes.juryList),
            ),
            _AdminMenuCard(
              icon: Icons.event_available,
              title: 'Jadwal Wawancara',
              subtitle: 'Kelola jadwal wawancara calon',
              onTap: () => _openRouteAndRefresh(AppRoutes.interviewList),
            ),
            // _AdminMenuCard(
            //   icon: Icons.analytics_outlined,
            //   title: 'Monitoring Nilai',
            //   subtitle: 'Pantau kelengkapan nilai calon, kriteria, dan juri',
            //   onTap: () => _openRouteAndRefresh(AppRoutes.scoreMonitoring),
            // ),
            _AdminMenuCard(
              icon: Icons.emoji_events,
              title: 'Hasil ARAS',
              subtitle: 'Lihat ranking akhir calon Duta Kampus',
              onTap: () => _openRouteAndRefresh(AppRoutes.arasResultList),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardStats {
  final PeriodModel? mainPeriod;
  final int totalPeriods;

  final int totalCandidates;
  final int pendingCandidates;
  final int validCandidates;
  final int invalidCandidates;
  final int scheduledCandidates;
  final int interviewedCandidates;
  final int scoredCandidates;

  final int totalJuries;
  final int activeJuries;

  final int totalCriteria;
  final int activeCriteria;

  const _DashboardStats({
    required this.mainPeriod,
    required this.totalPeriods,
    required this.totalCandidates,
    required this.pendingCandidates,
    required this.validCandidates,
    required this.invalidCandidates,
    required this.scheduledCandidates,
    required this.interviewedCandidates,
    required this.scoredCandidates,
    required this.totalJuries,
    required this.activeJuries,
    required this.totalCriteria,
    required this.activeCriteria,
  });

  factory _DashboardStats.empty() {
    return const _DashboardStats(
      mainPeriod: null,
      totalPeriods: 0,
      totalCandidates: 0,
      pendingCandidates: 0,
      validCandidates: 0,
      invalidCandidates: 0,
      scheduledCandidates: 0,
      interviewedCandidates: 0,
      scoredCandidates: 0,
      totalJuries: 0,
      activeJuries: 0,
      totalCriteria: 0,
      activeCriteria: 0,
    );
  }

  int _countStatus(List<CandidateModel> candidates, String status) {
    return candidates
        .where((candidate) => candidate.status.toLowerCase() == status)
        .length;
  }

  _DashboardStats copyWithCandidateData({
    required List<CandidateModel> allCandidates,
    required PeriodModel? mainPeriod,
  }) {
    final candidatesInPeriod = mainPeriod == null
        ? allCandidates
        : allCandidates
        .where((candidate) => candidate.periodId == mainPeriod.id)
        .toList();

    return _DashboardStats(
      mainPeriod: mainPeriod,
      totalPeriods: totalPeriods,
      totalCandidates: candidatesInPeriod.length,
      pendingCandidates: _countStatus(candidatesInPeriod, 'pending'),
      validCandidates: _countStatus(candidatesInPeriod, 'valid'),
      invalidCandidates: _countStatus(candidatesInPeriod, 'invalid'),
      scheduledCandidates: _countStatus(
        candidatesInPeriod,
        'interview_scheduled',
      ),
      interviewedCandidates: _countStatus(candidatesInPeriod, 'interviewed'),
      scoredCandidates: _countStatus(candidatesInPeriod, 'scored'),
      totalJuries: totalJuries,
      activeJuries: activeJuries,
      totalCriteria: totalCriteria,
      activeCriteria: activeCriteria,
    );
  }
}

class _AdminNotificationCard extends StatelessWidget {
  final int pendingCandidateCount;
  final int newCandidateCount;
  final int newPendingCandidateCount;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback onOpenCandidates;

  const _AdminNotificationCard({
    required this.pendingCandidateCount,
    required this.newCandidateCount,
    required this.newPendingCandidateCount,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onOpenCandidates,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Card(
        color: const Color(0xFFFEF2F2),
        child: ListTile(
          leading: const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          title: const Text(
            'Gagal Memuat Notifikasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(errorMessage!),
          trailing: IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ),
      );
    }

    if (isLoading && pendingCandidateCount == 0) {
      return const Card(
        child: ListTile(
          leading: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('Mengecek notifikasi...'),
          subtitle: Text('Sistem sedang memeriksa calon pending.'),
        ),
      );
    }

    final bool hasPending = pendingCandidateCount > 0;

    return Card(
      color: hasPending ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          hasPending ? Colors.orange.shade100 : Colors.green.shade100,
          child: Icon(
            hasPending
                ? Icons.notifications_active_outlined
                : Icons.check_circle_outline,
            color: hasPending ? Colors.orange.shade800 : Colors.green.shade800,
          ),
        ),
        title: Text(
          hasPending
              ? '$pendingCandidateCount Calon Pending'
              : 'Tidak Ada Calon Pending',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          hasPending
              ? newPendingCandidateCount > 0
              ? '$newPendingCandidateCount calon baru mendaftar dan menunggu validasi.'
              : 'Ada calon yang perlu divalidasi oleh admin.'
              : 'Semua data calon sudah diproses.',
        ),
        trailing: hasPending
            ? FilledButton(
          onPressed: onOpenCandidates,
          child: const Text('Cek'),
        )
            : IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.14),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E3A8A)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}