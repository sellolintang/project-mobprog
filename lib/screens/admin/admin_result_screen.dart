import 'package:flutter/material.dart';

import '../../app/colors.dart';

class AdminResultScreen extends StatelessWidget {
  const AdminResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = [
      {
        'rank': '1',
        'name': 'Ayu Lestari',
        'score': '0.942',
      },
      {
        'rank': '2',
        'name': 'Nabila Putri',
        'score': '0.918',
      },
      {
        'rank': '3',
        'name': 'Rizky Pratama',
        'score': '0.884',
      },
      {
        'rank': '4',
        'name': 'Fajar Ramadhan',
        'score': '0.801',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Ranking Akhir ARAS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Hasil ini merupakan simulasi perangkingan peserta berdasarkan nilai akhir.',
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
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 36,
              ),
              SizedBox(height: 14),
              Text(
                'Finalis Terbaik',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Ayu Lestari',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Skor ARAS: 0.942',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ...results.map((item) {
          return _ResultCard(
            rank: item['rank']!,
            name: item['name']!,
            score: item['score']!,
          );
        }),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String rank;
  final String name;
  final String score;

  const _ResultCard({
    required this.rank,
    required this.name,
    required this.score,
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
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              rank,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            score,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}