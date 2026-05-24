import 'package:flutter/material.dart';

import '../../app/colors.dart';

class AdminCriteriaScreen extends StatelessWidget {
  const AdminCriteriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final criteria = [
      {
        'name': 'Public Speaking',
        'weight': '30%',
        'type': 'Benefit',
      },
      {
        'name': 'Wawasan Kampus',
        'weight': '25%',
        'type': 'Benefit',
      },
      {
        'name': 'Kepribadian',
        'weight': '20%',
        'type': 'Benefit',
      },
      {
        'name': 'Prestasi',
        'weight': '15%',
        'type': 'Benefit',
      },
      {
        'name': 'Etika',
        'weight': '10%',
        'type': 'Benefit',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Kriteria Penilaian',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Bobot kriteria digunakan dalam simulasi perhitungan ARAS.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Total bobot kriteria harus bernilai 100%.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ...criteria.map((item) {
          return _CriteriaCard(
            name: item['name']!,
            weight: item['weight']!,
            type: item['type']!,
          );
        }),
      ],
    );
  }
}

class _CriteriaCard extends StatelessWidget {
  final String name;
  final String weight;
  final String type;

  const _CriteriaCard({
    required this.name,
    required this.weight,
    required this.type,
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
            child: const Icon(
              Icons.rule_rounded,
              color: AppColors.primary,
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
                  'Tipe: $type',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            weight,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}