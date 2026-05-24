import 'package:flutter/material.dart';

import '../app/colors.dart';
import '../app/routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Pilih Role',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masuk sebagai siapa?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih tampilan aplikasi berdasarkan peran pengguna.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),

            RoleCard(
              icon: Icons.admin_panel_settings_rounded,
              title: 'Administrator',
              subtitle: 'Kelola peserta, juri, kriteria, jadwal, dan hasil ARAS.',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.admin);
              },
            ),

            const SizedBox(height: 14),

            RoleCard(
              icon: Icons.rate_review_rounded,
              title: 'Juri',
              subtitle: 'Lihat peserta, input nilai wawancara, dan pantau hasil akhir.',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.jury);
              },
            ),

            const SizedBox(height: 14),

            RoleCard(
              icon: Icons.person_rounded,
              title: 'Peserta',
              subtitle: 'Isi pendaftaran, lihat status seleksi, jadwal, dan pengumuman.',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.participant);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}