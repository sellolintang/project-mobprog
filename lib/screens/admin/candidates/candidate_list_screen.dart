import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../models/candidate_model.dart';
import '../../../providers/candidate_provider.dart';

class CandidateListScreen extends StatefulWidget {
  const CandidateListScreen({super.key});

  @override
  State<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends State<CandidateListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CandidateProvider>().fetchCandidates();
    });
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

  Future<void> _deleteCandidate(CandidateModel candidate) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Calon'),
          content: Text('Yakin ingin menghapus ${candidate.fullName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final provider = context.read<CandidateProvider>();
    final success = await provider.deleteCandidate(candidate.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Data calon berhasil dihapus.'
              : provider.errorMessage ?? 'Gagal menghapus calon.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Calon'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchCandidates,
        child: Builder(
          builder: (context) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.errorMessage != null) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.fetchCandidates,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              );
            }

            if (provider.candidates.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.people_outline,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada data calon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.candidates.length,
              itemBuilder: (context, index) {
                final candidate = provider.candidates[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        candidate.fullName.isNotEmpty
                            ? candidate.fullName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      candidate.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(candidate.registrationNumber),
                          const SizedBox(height: 6),
                          Chip(
                            label: Text(
                              _statusLabel(candidate.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: _statusColor(candidate.status),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'detail') {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.candidateDetail,
                            arguments: candidate,
                          );
                        } else if (value == 'delete') {
                          _deleteCandidate(candidate);
                        }
                      },
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: 'detail',
                            child: Text('Detail'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus'),
                          ),
                        ];
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.candidateDetail,
                        arguments: candidate,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}