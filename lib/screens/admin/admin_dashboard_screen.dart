import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
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
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.candidateList);
            },
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