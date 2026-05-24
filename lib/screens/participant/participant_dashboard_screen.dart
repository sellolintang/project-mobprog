import 'package:flutter/material.dart';

import '../../app/colors.dart';

class ParticipantDashboardScreen extends StatelessWidget {
  const ParticipantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Halo, Ayu Lestari',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pantau status seleksi dan jadwal wawancara Anda.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 34,
                ),
                SizedBox(height: 14),
                Text(
                  'Status Saat Ini',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lulus Administrasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Silakan mengikuti tahap wawancara sesuai jadwal yang telah ditentukan.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Progress Seleksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          const _TimelineItem(
            title: 'Pendaftaran',
            subtitle: 'Formulir pendaftaran sudah dikirim.',
            status: 'Selesai',
            isDone: true,
          ),
          const _TimelineItem(
            title: 'Seleksi Administrasi',
            subtitle: 'Berkas pendaftaran sudah diverifikasi.',
            status: 'Selesai',
            isDone: true,
          ),
          const _TimelineItem(
            title: 'Wawancara',
            subtitle: 'Wawancara dijadwalkan pada Senin, 12 Mei 2025.',
            status: 'Berjalan',
            isDone: false,
          ),
          const _TimelineItem(
            title: 'Pengumuman Akhir',
            subtitle: 'Hasil akhir akan tampil setelah seluruh penilaian selesai.',
            status: 'Menunggu',
            isDone: false,
          ),

          const SizedBox(height: 20),

          const Text(
            'Informasi Penting',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          const _InfoCard(
            icon: Icons.calendar_month_rounded,
            title: 'Jadwal Wawancara',
            subtitle: 'Senin, 12 Mei 2025 pukul 09.00 di Ruang A.',
          ),
          const _InfoCard(
            icon: Icons.assignment_turned_in_rounded,
            title: 'Berkas Administrasi',
            subtitle: 'Seluruh berkas Anda telah diterima dan dinyatakan valid.',
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final bool isDone;

  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isDone ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isDone ? Icons.check_rounded : Icons.hourglass_top_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
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
                    fontWeight: FontWeight.w800,
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