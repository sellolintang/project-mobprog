import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class JuryDashboardScreen extends StatelessWidget {
  const JuryDashboardScreen({super.key});

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
        title: const Text('Dashboard Juri'),
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
                child: Icon(Icons.person),
              ),
              title: Text(user?.name ?? 'Juri'),
              subtitle: Text(user?.email ?? '-'),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Menu Juri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _JuryMenuCard(
            icon: Icons.assignment_ind,
            title: 'Calon yang Dinilai',
            subtitle: 'Lihat daftar calon Duta Kampus',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.scoringCandidates);
            },
          ),
          _JuryMenuCard(
            icon: Icons.edit_note,
            title: 'Input Nilai',
            subtitle: 'Pilih calon dan isi nilai berdasarkan kriteria',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.scoringCandidates);
            },
          ),
          _JuryMenuCard(
            icon: Icons.history,
            title: 'Riwayat Penilaian',
            subtitle: 'Lihat nilai yang sudah diberikan',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.scoringHistory);
            },
          ),
        ],
      ),
    );
  }
}

class _JuryMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _JuryMenuCard({
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