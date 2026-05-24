import 'package:flutter/material.dart';

import '../../app/colors.dart';

class JuryResultScreen extends StatelessWidget {
  const JuryResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = [
      {
        'name': 'Ayu Lestari',
        'major': 'Teknik Informatika',
        'score': '86.75',
        'status': 'Sudah Dinilai',
      },
      {
        'name': 'Nabila Putri',
        'major': 'Administrasi Bisnis',
        'score': '84.20',
        'status': 'Sudah Dinilai',
      },
      {
        'name': 'Rizky Pratama',
        'major': 'Akuntansi',
        'score': '81.50',
        'status': 'Sudah Dinilai',
      },
      {
        'name': 'Fajar Ramadhan',
        'major': 'Teknik Elektro',
        'score': '-',
        'status': 'Belum Dinilai',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Hasil Penilaian Saya',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Daftar nilai peserta yang sudah dan belum Anda input.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        ...results.map((item) {
          return _JuryResultCard(
            name: item['name']!,
            major: item['major']!,
            score: item['score']!,
            status: item['status']!,
          );
        }),
      ],
    );
  }
}

class _JuryResultCard extends StatelessWidget {
  final String name;
  final String major;
  final String score;
  final String status;

  const _JuryResultCard({
    required this.name,
    required this.major,
    required this.score,
    required this.status,
  });

  bool get isScored => status == 'Sudah Dinilai';

  @override
  Widget build(BuildContext context) {
    final statusColor = isScored ? AppColors.success : AppColors.warning;

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
                fontWeight: FontWeight.w900,
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
          Text(
            score,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isScored ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}