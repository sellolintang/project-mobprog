import 'package:flutter/material.dart';

import '../../app/colors.dart';

class AdminParticipantScreen extends StatelessWidget {
  const AdminParticipantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final participants = [
      {
        'name': 'Ayu Lestari',
        'major': 'Teknik Informatika',
        'status': 'Lulus Admin',
      },
      {
        'name': 'Rizky Pratama',
        'major': 'Akuntansi',
        'status': 'Menunggu',
      },
      {
        'name': 'Nabila Putri',
        'major': 'Administrasi Bisnis',
        'status': 'Lulus Admin',
      },
      {
        'name': 'Fajar Ramadhan',
        'major': 'Teknik Elektro',
        'status': 'Tidak Lulus',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Daftar Peserta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kelola data peserta yang sudah mendaftar.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        TextField(
          decoration: InputDecoration(
            hintText: 'Cari peserta...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list_rounded),
            ),
          ),
        ),

        const SizedBox(height: 20),

        ...participants.map((participant) {
          return _ParticipantCard(
            name: participant['name']!,
            major: participant['major']!,
            status: participant['status']!,
          );
        }),
      ],
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final String name;
  final String major;
  final String status;

  const _ParticipantCard({
    required this.name,
    required this.major,
    required this.status,
  });

  Color getStatusColor() {
    if (status == 'Lulus Admin') return AppColors.success;
    if (status == 'Tidak Lulus') return AppColors.danger;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor();

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
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              name[0],
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  major,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
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
    );
  }
}