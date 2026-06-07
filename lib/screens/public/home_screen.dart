import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF1E3A8A),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Duta Kampus Mobile'),
        // actions: [
        //   TextButton.icon(
        //     onPressed: () {
        //       Navigator.pushNamed(context, AppRoutes.login);
        //     },
        //     icon: const Icon(Icons.login),
        //     label: const Text('Login'),
        //   ),
        // ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 56,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Pemilihan Duta Kampus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aplikasi mobile untuk pendaftaran calon, penilaian juri, dan perhitungan ranking menggunakan metode ARAS.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Menu Publik',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _menuCard(
            icon: Icons.app_registration,
            title: 'Pendaftaran Calon',
            subtitle: 'Form pendaftaran calon Duta Kampus',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.candidateRegistration);
            },
          ),

          _menuCard(
            icon: Icons.emoji_events,
            title: 'Hasil Pemilihan',
            subtitle: 'Lihat hasil ranking Duta Kampus',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.publicResult);
            },
          ),

          _menuCard(
            icon: Icons.login,
            title: 'Login Admin/Juri',
            subtitle: 'Masuk sebagai admin atau juri',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}