import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/score_model.dart';
import '../../providers/period_provider.dart';
import '../../providers/score_provider.dart';

class ScoringHistoryScreen extends StatefulWidget {
  const ScoringHistoryScreen({super.key});

  @override
  State<ScoringHistoryScreen> createState() => _ScoringHistoryScreenState();
}

class _ScoringHistoryScreenState extends State<ScoringHistoryScreen> {
  int? _selectedPeriodId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final periodProvider = context.read<PeriodProvider>();
      final scoreProvider = context.read<ScoreProvider>();

      await periodProvider.fetchPeriods();

      if (!mounted) return;

      if (periodProvider.periods.isNotEmpty) {
        _selectedPeriodId = periodProvider.periods.first.id;
        await scoreProvider.fetchHistory(periodId: _selectedPeriodId!);
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

  void _openScoringForm(ScoreCandidateModel candidate) {
    if (_selectedPeriodId == null) return;

    Navigator.pushNamed(
      context,
      AppRoutes.scoringForm,
      arguments: {
        'period_id': _selectedPeriodId,
        'candidate': candidate,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();
    final scoreProvider = context.watch<ScoreProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penilaian'),
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
                if (value == null) return;

                setState(() {
                  _selectedPeriodId = value;
                });

                final provider = context.read<ScoreProvider>();
                await provider.fetchHistory(periodId: value);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_selectedPeriodId == null) return;

                final provider = context.read<ScoreProvider>();
                await provider.fetchHistory(periodId: _selectedPeriodId!);
              },
              child: Builder(
                builder: (context) {
                  if (scoreProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (scoreProvider.errorMessage != null) {
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
                          scoreProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    );
                  }

                  if (scoreProvider.histories.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.history,
                          size: 72,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat penilaian.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: scoreProvider.histories.length,
                    itemBuilder: (context, index) {
                      final item = scoreProvider.histories[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              item.fullName.isNotEmpty
                                  ? item.fullName[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(
                            item.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.registrationNumber),
                                Text(item.studyProgram ?? '-'),
                                const SizedBox(height: 6),
                                Text(
                                  'Nilai rata-rata: ${item.averageScore?.toStringAsFixed(2) ?? '-'}',
                                ),
                                Text(
                                  'Progress: ${item.scoredCriteriaCount}/${item.assignedCriteriaCount} kriteria',
                                ),
                                Text(
                                  'Update terakhir: ${_formatDate(item.lastUpdatedAt)}',
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openScoringForm(item),
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