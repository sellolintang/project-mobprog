import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/candidate_model.dart';
import '../../../providers/candidate_provider.dart';
import '../../../core/constants/api_constants.dart';

class CandidateDetailScreen extends StatelessWidget {
  const CandidateDetailScreen({super.key});

  Future<void> _validateCandidate(
      BuildContext context,
      CandidateModel candidate,
      ) async {
    final provider = context.read<CandidateProvider>();

    final success = await provider.validateCandidate(
      candidate.id,
      candidate.fullName,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Calon berhasil divalidasi.'
              : provider.errorMessage ?? 'Gagal memvalidasi calon.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  Future<void> _rejectCandidate(
      BuildContext context,
      CandidateModel candidate,
      ) async {
    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tolak Calon'),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Alasan penolakan',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  reasonController.text.trim(),
                );
              },
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null || reason.isEmpty || !context.mounted) return;

    final provider = context.read<CandidateProvider>();

    final success = await provider.rejectCandidate(
      id: candidate.id,
      candidateName: candidate.fullName,
      rejectionReason: reason,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Calon berhasil ditolak.'
              : provider.errorMessage ?? 'Gagal menolak calon.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  Widget _infoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value == null || value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'valid':
        return Colors.green;
      case 'invalid':
        return Colors.red;
      case 'interview_scheduled':
        return Colors.blue;
      case 'interviewed':
        return Colors.purple;
      case 'scored':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'valid':
        return 'Valid';
      case 'invalid':
        return 'Ditolak';
      case 'interview_scheduled':
        return 'Dijadwalkan';
      case 'interviewed':
        return 'Wawancara';
      case 'scored':
        return 'Sudah Dinilai';
      default:
        return status;
    }
  }

  String? _storageUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final baseServerUrl = ApiConstants.baseUrl.replaceFirst(
      RegExp(r'/api/?$'),
      '',
    );

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return '$baseServerUrl/storage/$cleanPath';
  }

  Future<void> _openFile(BuildContext context, String? path) async {
    final url = _storageUrl(path);

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File belum tersedia.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uri = Uri.parse(url);

    final canOpen = await canLaunchUrl(uri);

    if (!canOpen) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka file: $url'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Widget _documentButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String? path,
  }) {
    final available = path != null && path.trim().isNotEmpty;

    return OutlinedButton.icon(
      onPressed: available ? () => _openFile(context, path) : null,
      icon: Icon(icon),
      label: Text(available ? label : '$label belum tersedia'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is! CandidateModel) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Calon')),
        body: const Center(
          child: Text('Data calon tidak ditemukan.'),
        ),
      );
    }

    final candidate = args;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Calon'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    child: Text(
                      candidate.fullName.isNotEmpty
                          ? candidate.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    candidate.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      _statusLabel(candidate.status),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _statusColor(candidate.status),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoItem('Nomor Pendaftaran', candidate.registrationNumber),
                  _infoItem('NIM', candidate.studentNumber),
                  _infoItem('Email', candidate.email),
                  _infoItem('No. HP', candidate.phone),
                  _infoItem('Fakultas', candidate.faculty),
                  _infoItem('Program Studi', candidate.studyProgram),
                  _infoItem(
                    'Semester',
                    candidate.semester?.toString(),
                  ),
                  _infoItem('Visi', candidate.vision),
                  _infoItem('Misi', candidate.mission),
                  const SizedBox(height: 12),

                  const Divider(),

                  const SizedBox(height: 12),

                  const Text(
                    'Dokumen Pendaftaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _documentButton(
                    context: context,
                    label: 'Buka Foto Calon',
                    icon: Icons.image_outlined,
                    path: candidate.photoFile,
                  ),

                  const SizedBox(height: 8),

                  _documentButton(
                    context: context,
                    label: 'Buka CV / Berkas',
                    icon: Icons.description_outlined,
                    path: candidate.cvFile,
                  ),
                  _infoItem('Alasan Penolakan', candidate.rejectionReason),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (candidate.status == 'pending') ...[
            ElevatedButton.icon(
              onPressed: () => _validateCandidate(context, candidate),
              icon: const Icon(Icons.check_circle),
              label: const Text('Validasi Calon'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _rejectCandidate(context, candidate),
              icon: const Icon(Icons.cancel),
              label: const Text('Tolak Calon'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}