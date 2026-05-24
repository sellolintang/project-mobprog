import 'package:flutter/material.dart';

import '../app/colors.dart';
import '../app/routes.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Pemilihan Duta PNJ 2025',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Aplikasi mobile untuk mendukung proses seleksi duta, mulai dari pendaftaran, verifikasi, penilaian juri, hingga hasil akhir berbasis ARAS.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              _InfoCard(
                icon: Icons.verified_user_rounded,
                title: 'Seleksi Terstruktur',
                subtitle: 'Proses seleksi dibuat rapi dari tahap administrasi sampai wawancara.',
              ),

              const SizedBox(height: 12),

              _InfoCard(
                icon: Icons.analytics_rounded,
                title: 'Metode ARAS',
                subtitle: 'Hasil akhir ditampilkan dalam bentuk ranking yang mudah dibaca.',
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.roleSelection);
                  },
                  child: const Text(
                    'Mulai Sekarang',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
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
        ],
      ),
    );
  }
}