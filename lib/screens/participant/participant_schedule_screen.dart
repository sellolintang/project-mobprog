import 'package:flutter/material.dart';

import '../../app/colors.dart';

class ParticipantScheduleScreen extends StatelessWidget {
  const ParticipantScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Jadwal Wawancara Anda',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pastikan hadir sesuai jadwal yang telah ditentukan.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 36,
              ),
              SizedBox(height: 16),
              Text(
                'Senin, 12 Mei 2025',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '09.00 - 09.30 WIB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Ruang A, Gedung Direktorat PNJ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Detail Wawancara',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        const _ScheduleDetailItem(
          icon: Icons.person_rounded,
          title: 'Nama Peserta',
          value: 'Ayu Lestari',
        ),
        const _ScheduleDetailItem(
          icon: Icons.school_rounded,
          title: 'Program Studi',
          value: 'Teknik Informatika',
        ),
        const _ScheduleDetailItem(
          icon: Icons.meeting_room_rounded,
          title: 'Ruangan',
          value: 'Ruang A',
        ),
        const _ScheduleDetailItem(
          icon: Icons.groups_rounded,
          title: 'Juri',
          value: 'Tim Juri 1',
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.warning,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Peserta disarankan hadir 15 menit sebelum wawancara dimulai dan membawa kartu mahasiswa.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleDetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ScheduleDetailItem({
    required this.icon,
    required this.title,
    required this.value,
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
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
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