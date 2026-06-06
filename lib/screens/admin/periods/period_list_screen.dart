import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../models/period_model.dart';
import '../../../providers/period_provider.dart';

class PeriodListScreen extends StatefulWidget {
  const PeriodListScreen({super.key});

  @override
  State<PeriodListScreen> createState() => _PeriodListScreenState();
}

class _PeriodListScreenState extends State<PeriodListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PeriodProvider>().fetchPeriods();
    });
  }

  Future<void> _deletePeriod(PeriodModel period) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Periode'),
          content: Text(
            'Yakin ingin menghapus periode ${period.electionYear}?',
          ),
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

    final provider = context.read<PeriodProvider>();
    final success = await provider.deletePeriod(period.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Periode berhasil dihapus.'
              : provider.errorMessage ?? 'Gagal menghapus periode.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'registration':
        return Colors.blue;
      case 'interview':
        return Colors.orange;
      case 'scoring':
        return Colors.purple;
      case 'finished':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'registration':
        return 'Pendaftaran';
      case 'interview':
        return 'Wawancara';
      case 'scoring':
        return 'Penilaian';
      case 'finished':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeriodProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Periode Pemilihan'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.periodForm);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchPeriods,
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
                    onPressed: provider.fetchPeriods,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              );
            }

            if (provider.periods.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.event_busy,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada data periode.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.periods.length,
              itemBuilder: (context, index) {
                final period = provider.periods[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(period.electionYear.toString()),
                    ),
                    title: Text(
                      'Pemilihan Duta Kampus ${period.electionYear}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              _getStatusLabel(period.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: _getStatusColor(period.status),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.periodForm,
                            arguments: period,
                          );
                        } else if (value == 'delete') {
                          _deletePeriod(period);
                        }
                      },
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus'),
                          ),
                        ];
                      },
                    ),
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