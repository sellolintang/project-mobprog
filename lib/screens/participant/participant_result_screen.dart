import 'package:flutter/material.dart';

import '../../app/colors.dart';

class ParticipantResultScreen extends StatelessWidget {
  const ParticipantResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isFinalResultPublished = true;

    if (!isFinalResultPublished) {
      return const _WaitingResultView();
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Hasil Seleksi Anda',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Berikut hasil akhir simulasi seleksi Duta PNJ 2025.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(height: 16),
              Text(
                'Selamat!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Anda masuk dalam daftar finalis terbaik Duta PNJ 2025.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Ringkasan Nilai',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        const _ScoreSummaryCard(
          title: 'Nilai Wawancara',
          value: '86.75',
          icon: Icons.rate_review_rounded,
        ),
        const _ScoreSummaryCard(
          title: 'Skor ARAS',
          value: '0.942',
          icon: Icons.analytics_rounded,
        ),
        const _ScoreSummaryCard(
          title: 'Peringkat',
          value: '1',
          icon: Icons.leaderboard_rounded,
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
                color: AppColors.primary,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hasil ini merupakan data simulasi untuk kebutuhan UI/UX. Pada sistem asli, hasil akan ditentukan setelah seluruh penilaian juri selesai diproses.',
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

class _WaitingResultView extends StatelessWidget {
  const _WaitingResultView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Hasil akhir belum dipublikasikan.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ScoreSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ScoreSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
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
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}