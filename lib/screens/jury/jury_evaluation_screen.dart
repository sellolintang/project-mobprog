import 'package:flutter/material.dart';

import '../../app/colors.dart';

class JuryEvaluationScreen extends StatefulWidget {
  const JuryEvaluationScreen({super.key});

  @override
  State<JuryEvaluationScreen> createState() => _JuryEvaluationScreenState();
}

class _JuryEvaluationScreenState extends State<JuryEvaluationScreen> {
  double publicSpeaking = 80;
  double wawasanKampus = 75;
  double kepribadian = 85;
  double prestasi = 70;
  double etika = 90;

  double get finalScore {
    return (publicSpeaking * 0.30) +
        (wawasanKampus * 0.25) +
        (kepribadian * 0.20) +
        (prestasi * 0.15) +
        (etika * 0.10);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Form Penilaian',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Berikan nilai peserta berdasarkan kriteria seleksi.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  'A',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ayu Lestari',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Teknik Informatika',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sesi wawancara: 09.00 - 09.30',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _ScoreSlider(
          title: 'Public Speaking',
          weight: '30%',
          value: publicSpeaking,
          onChanged: (value) {
            setState(() {
              publicSpeaking = value;
            });
          },
        ),
        _ScoreSlider(
          title: 'Wawasan Kampus',
          weight: '25%',
          value: wawasanKampus,
          onChanged: (value) {
            setState(() {
              wawasanKampus = value;
            });
          },
        ),
        _ScoreSlider(
          title: 'Kepribadian',
          weight: '20%',
          value: kepribadian,
          onChanged: (value) {
            setState(() {
              kepribadian = value;
            });
          },
        ),
        _ScoreSlider(
          title: 'Prestasi',
          weight: '15%',
          value: prestasi,
          onChanged: (value) {
            setState(() {
              prestasi = value;
            });
          },
        ),
        _ScoreSlider(
          title: 'Etika',
          weight: '10%',
          value: etika,
          onChanged: (value) {
            setState(() {
              etika = value;
            });
          },
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calculate_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Nilai Akhir',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                finalScore.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Catatan penilaian juri...',
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nilai peserta berhasil disimpan.'),
                ),
              );
            },
            icon: const Icon(Icons.save_rounded),
            label: const Text(
              'Simpan Penilaian',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreSlider extends StatelessWidget {
  final String title;
  final String weight;
  final double value;
  final ValueChanged<double> onChanged;

  const _ScoreSlider({
    required this.title,
    required this.weight,
    required this.value,
    required this.onChanged,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Bobot $weight',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: value.round().toString(),
                  activeColor: AppColors.primary,
                  onChanged: onChanged,
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  value.round().toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}