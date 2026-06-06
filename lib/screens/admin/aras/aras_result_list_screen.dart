import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/aras_result_model.dart';
import '../../../providers/aras_result_provider.dart';
import '../../../providers/period_provider.dart';

class ArasResultListScreen extends StatefulWidget {
  const ArasResultListScreen({super.key});

  @override
  State<ArasResultListScreen> createState() => _ArasResultListScreenState();
}

class _ArasResultListScreenState extends State<ArasResultListScreen> {
  int? _selectedPeriodId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await context.read<PeriodProvider>().fetchPeriods();

      if (!mounted) return;

      final periods = context.read<PeriodProvider>().periods;

      if (periods.isNotEmpty) {
        _selectedPeriodId = periods.first.id;
        await context
            .read<ArasResultProvider>()
            .fetchResults(periodId: _selectedPeriodId);
      } else {
        await context.read<ArasResultProvider>().fetchResults();
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Future<void> _calculateAras() async {
    if (_selectedPeriodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih periode terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hitung ARAS'),
          content: const Text(
            'Yakin ingin menghitung ulang hasil ARAS untuk periode ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hitung'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final provider = context.read<ArasResultProvider>();
    final success = await provider.calculateResults(_selectedPeriodId!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Perhitungan ARAS berhasil dilakukan.'
              : provider.errorMessage ?? 'Perhitungan ARAS gagal.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _deleteResult(ArasResultModel result) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Hasil'),
          content: Text(
            'Yakin ingin menghapus hasil ${result.candidateName ?? '-'}?',
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

    final provider = context.read<ArasResultProvider>();
    final success = await provider.deleteResult(
      result.id,
      periodId: _selectedPeriodId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Hasil ARAS berhasil dihapus.'
              : provider.errorMessage ?? 'Gagal menghapus hasil ARAS.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _rankBadge(int rank) {
    Color color = Colors.grey;

    if (rank == 1) {
      color = Colors.amber;
    } else if (rank == 2) {
      color = Colors.blueGrey;
    } else if (rank == 3) {
      color = Colors.brown;
    }

    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        rank.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arasProvider = context.watch<ArasResultProvider>();
    final periodProvider = context.watch<PeriodProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil ARAS'),
        actions: [
          IconButton(
            onPressed: _calculateAras,
            icon: const Icon(Icons.calculate),
            tooltip: 'Hitung ARAS',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<int>(
              initialValue: _selectedPeriodId,
              decoration: const InputDecoration(
                labelText: 'Periode Pemilihan',
                prefixIcon: Icon(Icons.event_note),
                border: OutlineInputBorder(),
              ),
              items: periodProvider.periods.map((period) {
                return DropdownMenuItem<int>(
                  value: period.id,
                  child: Text('Duta Kampus ${period.electionYear}'),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  _selectedPeriodId = value;
                });

                await context
                    .read<ArasResultProvider>()
                    .fetchResults(periodId: value);
              },
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                return context
                    .read<ArasResultProvider>()
                    .fetchResults(periodId: _selectedPeriodId);
              },
              child: Builder(
                builder: (context) {
                  if (arasProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (arasProvider.errorMessage != null) {
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
                          arasProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ArasResultProvider>()
                                .fetchResults(periodId: _selectedPeriodId);
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    );
                  }

                  if (arasProvider.results.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 72,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada hasil ARAS. Tekan tombol kalkulator untuk menghitung hasil.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: arasProvider.results.length,
                    itemBuilder: (context, index) {
                      final result = arasProvider.results[index];

                      return Card(
                        child: ListTile(
                          leading: _rankBadge(result.finalRank),
                          title: Text(
                            result.candidateName ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.registrationNumber ?? '-',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Score: ${result.totalScore.toStringAsFixed(6)}',
                                ),
                                Text(
                                  'Utility Score: ${result.utilityScore.toStringAsFixed(6)}',
                                ),
                                Text(
                                  'Dihitung: ${_formatDate(result.calculatedAt)}',
                                ),
                              ],
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteResult(result);
                              }
                            },
                            itemBuilder: (context) {
                              return const [
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
          ),
        ],
      ),
    );
  }
}