import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/aras_result_model.dart';
import '../../providers/aras_result_provider.dart';
import '../../providers/period_provider.dart';

class PublicResultScreen extends StatefulWidget {
  const PublicResultScreen({super.key});

  @override
  State<PublicResultScreen> createState() => _PublicResultScreenState();
}

class _PublicResultScreenState extends State<PublicResultScreen> {
  int? _selectedPeriodId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final periodProvider = context.read<PeriodProvider>();
      final resultProvider = context.read<ArasResultProvider>();

      await periodProvider.fetchPeriods();

      if (!mounted) return;

      if (periodProvider.periods.isNotEmpty) {
        _selectedPeriodId = periodProvider.periods.first.id;

        await resultProvider.fetchResults(
          periodId: _selectedPeriodId,
        );
      } else {
        await resultProvider.fetchResults();
      }

      if (mounted) {
        setState(() {});
      }
    });
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

  Widget _resultCard(ArasResultModel result) {
    return Card(
      child: ListTile(
        leading: _rankBadge(result.finalRank),
        title: Text(
          result.candidateName ?? '-',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.registrationNumber ?? '-'),
              Text(result.studyProgram ?? '-'),
              const SizedBox(height: 6),
              Text(
                'Utility Score: ${result.utilityScore.toStringAsFixed(6)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();
    final resultProvider = context.watch<ArasResultProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Pemilihan'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 12),
                Text(
                  'Hasil Ranking Duta Kampus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Ranking dihitung berdasarkan metode ARAS dari nilai juri dan bobot kriteria.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

                await context.read<ArasResultProvider>().fetchResults(
                  periodId: value,
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                return context.read<ArasResultProvider>().fetchResults(
                  periodId: _selectedPeriodId,
                );
              },
              child: Builder(
                builder: (context) {
                  if (resultProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (resultProvider.errorMessage != null) {
                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 64,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          resultProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Catatan: apabila endpoint hasil masih dilindungi token, halaman publik ini perlu dibuka dari sisi backend.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    );
                  }

                  if (resultProvider.results.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: const [
                        SizedBox(height: 90),
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 72,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Hasil pemilihan belum tersedia.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: resultProvider.results.length,
                    itemBuilder: (context, index) {
                      return _resultCard(resultProvider.results[index]);
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