import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_notification_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminNotificationService _adminNotificationService =
  AdminNotificationService();

  Timer? _notificationTimer;

  bool _isCheckingNotification = false;
  String? _notificationError;
  int _pendingCandidateCount = 0;
  int _newCandidateCount = 0;
  int _newPendingCandidateCount = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkAdminNotifications();
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

      if (!mounted) return;

      setState(() {
        _pendingCandidateCount = result.pendingCount;
        _newCandidateCount = result.newCandidateCount;
        _newPendingCandidateCount = result.newPendingCount;
        _isCheckingNotification = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCheckingNotification = false;
        _notificationError =
            e.toString().replaceFirst('Exception: ', '');
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

    await _checkAdminNotifications(showLocalNotification: false);
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
            tooltip: 'Refresh notifikasi',
            onPressed: _isCheckingNotification
                ? null
                : () => _checkAdminNotifications(),
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
        onRefresh: () => _checkAdminNotifications(),
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
              subtitle: 'Kelola tahun dan status pemilihan',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.periodList);
              },
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
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.criterionList);
              },
            ),
            _AdminMenuCard(
              icon: Icons.groups,
              title: 'Data Juri',
              subtitle: 'Kelola akun juri dan pembagian kriteria',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.juryList);
              },
            ),
            _AdminMenuCard(
              icon: Icons.event_available,
              title: 'Jadwal Wawancara',
              subtitle: 'Kelola jadwal wawancara calon',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.interviewList);
              },
            ),
            _AdminMenuCard(
              icon: Icons.emoji_events,
              title: 'Hasil ARAS',
              subtitle: 'Lihat ranking akhir calon Duta Kampus',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.arasResultList);
              },
            ),
          ],
        ),
      ),
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