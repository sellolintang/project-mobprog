import 'package:flutter/material.dart';

import '../../app/colors.dart';

class ParticipantRegistrationScreen extends StatefulWidget {
  const ParticipantRegistrationScreen({super.key});

  @override
  State<ParticipantRegistrationScreen> createState() =>
      _ParticipantRegistrationScreenState();
}

class _ParticipantRegistrationScreenState
    extends State<ParticipantRegistrationScreen> {
  final TextEditingController nameController =
  TextEditingController(text: 'Ayu Lestari');
  final TextEditingController nimController =
  TextEditingController(text: '2307411001');
  final TextEditingController majorController =
  TextEditingController(text: 'Teknik Informatika');
  final TextEditingController phoneController =
  TextEditingController(text: '081234567890');
  final TextEditingController motivationController = TextEditingController(
    text:
    'Saya ingin menjadi Duta PNJ untuk berkontribusi dalam kegiatan kampus dan memperkenalkan nilai positif mahasiswa PNJ.',
  );

  @override
  void dispose() {
    nameController.dispose();
    nimController.dispose();
    majorController.dispose();
    phoneController.dispose();
    motivationController.dispose();
    super.dispose();
  }

  void submitForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulir pendaftaran berhasil disimpan.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Data Pendaftaran',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Lengkapi data diri dan motivasi pendaftaran Anda.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        _FormSection(
          title: 'Data Pribadi',
          children: [
            _InputField(
              label: 'Nama Lengkap',
              controller: nameController,
              icon: Icons.person_rounded,
            ),
            _InputField(
              label: 'NIM',
              controller: nimController,
              icon: Icons.badge_rounded,
            ),
            _InputField(
              label: 'Program Studi',
              controller: majorController,
              icon: Icons.school_rounded,
            ),
            _InputField(
              label: 'Nomor Telepon',
              controller: phoneController,
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),

        const SizedBox(height: 18),

        _FormSection(
          title: 'Motivasi',
          children: [
            TextField(
              controller: motivationController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Motivasi Mengikuti Pemilihan Duta',
                prefixIcon: Icon(Icons.edit_note_rounded),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dokumen Pendukung',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _DocumentItem(
                title: 'Foto Formal',
                status: 'Sudah diunggah',
                isUploaded: true,
              ),
              _DocumentItem(
                title: 'Kartu Mahasiswa',
                status: 'Sudah diunggah',
                isUploaded: true,
              ),
              _DocumentItem(
                title: 'Sertifikat Prestasi',
                status: 'Opsional',
                isUploaded: false,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: submitForm,
            icon: const Icon(Icons.save_rounded),
            label: const Text(
              'Simpan Formulir',
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

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSection({
    required this.title,
    required this.children,
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
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;

  const _InputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final String title;
  final String status;
  final bool isUploaded;

  const _DocumentItem({
    required this.title,
    required this.status,
    required this.isUploaded,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isUploaded ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            isUploaded
                ? Icons.check_circle_rounded
                : Icons.upload_file_rounded,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
    );
  }
}