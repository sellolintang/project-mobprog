import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/score_model.dart';
import '../../providers/period_provider.dart';
import '../../providers/score_provider.dart';

class ScoringCandidateScreen extends StatefulWidget {
  const ScoringCandidateScreen({super.key});

  @override
  State<ScoringCandidateScreen> createState() => _ScoringCandidateScreenState();
}

class _ScoringCandidateScreenState extends State<ScoringCandidateScreen> {
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
        await scoreProvider.fetchCandidates(periodId: _selectedPeriodId!);
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  Color _statusColor(bool isComplete) {
    return isComplete ? Colors.green : Colors.orange;
  }

  String _statusText(bool isComplete) {
    return isComplete ? 'Lengkap' : 'Belum Lengkap';
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
        title: const Text('Calon yang Dinilai'),
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
                await provider.fetchCandidates(periodId: value);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_selectedPeriodId == null) return;

                final provider = context.read<ScoreProvider>();
                await provider.fetchCandidates(periodId: _selectedPeriodId!);
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

                  if (scoreProvider.candidates.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.assignment_ind_outlined,
                          size: 72,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada calon yang dapat dinilai.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: scoreProvider.candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = scoreProvider.candidates[index];

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
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(candidate.registrationNumber),
                                Text(candidate.studyProgram ?? '-'),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    Chip(
                                      label: Text(
                                        _statusText(candidate.isComplete),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor:
                                      _statusColor(candidate.isComplete),
                                    ),
                                    Chip(
                                      label: Text(
                                        '${candidate.scoredCriteriaCount}/${candidate.assignedCriteriaCount} kriteria',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openScoringForm(candidate),
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