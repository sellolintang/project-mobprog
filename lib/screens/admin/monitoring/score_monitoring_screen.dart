import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/period_model.dart';
import '../../../models/score_monitoring_model.dart';
import '../../../providers/period_provider.dart';
import '../../../services/monitoring_service.dart';

class ScoreMonitoringScreen extends StatefulWidget {
  const ScoreMonitoringScreen({super.key});

  @override
  State<ScoreMonitoringScreen> createState() => _ScoreMonitoringScreenState();
}

class _ScoreMonitoringScreenState extends State<ScoreMonitoringScreen> {
  final MonitoringService _monitoringService = MonitoringService();

  int? _selectedPeriodId;
  ScoreMonitoringModel? _monitoringData;

  bool _isLoading = false;
  String? _errorMessage;

  String _selectedTab = 'candidates';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final periodProvider = context.read<PeriodProvider>();

    await periodProvider.fetchPeriods();

    if (!mounted) return;

    if (periodProvider.periods.isNotEmpty) {
      final sortedPeriods = List<PeriodModel>.from(periodProvider.periods)
        ..sort((a, b) => b.electionYear.compareTo(a.electionYear));

      setState(() {
        _selectedPeriodId = sortedPeriods.first.id;
      });

      await _fetchMonitoring();
    }
  }

  Future<void> _fetchMonitoring() async {
    if (_selectedPeriodId == null) {
      setState(() {
        _errorMessage = 'Pilih periode terlebih dahulu.';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await _monitoringService.getScoreMonitoring(
        periodId: _selectedPeriodId!,
      );

      if (!mounted) return;

      setState(() {
        _monitoringData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Color _progressColor(double value) {
    if (value >= 100) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _periodSelector(PeriodProvider periodProvider) {
    if (periodProvider.isLoading && periodProvider.periods.isEmpty) {
      return const Card(
        child: ListTile(
          leading: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('Memuat periode...'),
        ),
      );
    }

    if (periodProvider.periods.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.event_busy, color: Colors.orange),
          title: Text('Belum ada periode'),
          subtitle: Text('Buat periode pemilihan terlebih dahulu.'),
        ),
      );
    }

    final sortedPeriods = List<PeriodModel>.from(periodProvider.periods)
      ..sort((a, b) => b.electionYear.compareTo(a.electionYear));

    return DropdownButtonFormField<int>(
      value: _selectedPeriodId,
      decoration: const InputDecoration(
        labelText: 'Periode Pemilihan',
        prefixIcon: Icon(Icons.event_note),
        border: OutlineInputBorder(),
      ),
      items: sortedPeriods.map((period) {
        return DropdownMenuItem<int>(
          value: period.id,
          child: Text('Duta Kampus ${period.electionYear}'),
        );
      }).toList(),
      onChanged: (value) async {
        setState(() {
          _selectedPeriodId = value;
          _monitoringData = null;
          _errorMessage = null;
        });

        await _fetchMonitoring();
      },
    );
  }

  Widget _summaryCard(ScoreMonitoringSummaryModel summary) {
    final progress = summary.completionPercentage.clamp(0, 100).toDouble();
    final color = _progressColor(progress);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ringkasan Monitoring',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(Icons.analytics_outlined, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${progress.toStringAsFixed(2)}% lengkap',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MiniStatCard(
                  title: 'Total Calon',
                  value: summary.totalCandidates.toString(),
                  icon: Icons.people_alt,
                  color: Colors.blue,
                ),
                _MiniStatCard(
                  title: 'Lengkap',
                  value: summary.completeCandidates.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                _MiniStatCard(
                  title: 'Belum Lengkap',
                  value: summary.incompleteCandidates.toString(),
                  icon: Icons.warning_amber_outlined,
                  color: Colors.orange,
                ),
                _MiniStatCard(
                  title: 'Kriteria',
                  value: summary.criteriaCount.toString(),
                  icon: Icons.rule,
                  color: Colors.purple,
                ),
                _MiniStatCard(
                  title: 'Juri',
                  value: summary.juriesCount.toString(),
                  icon: Icons.groups,
                  color: Colors.teal,
                ),
                _MiniStatCard(
                  title: 'Record Nilai',
                  value: summary.scoreRecordsCount.toString(),
                  icon: Icons.assignment_turned_in_outlined,
                  color: Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          selected: _selectedTab == 'candidates',
          label: const Text('Per Calon'),
          onSelected: (_) {
            setState(() {
              _selectedTab = 'candidates';
            });
          },
        ),
        ChoiceChip(
          selected: _selectedTab == 'criteria',
          label: const Text('Per Kriteria'),
          onSelected: (_) {
            setState(() {
              _selectedTab = 'criteria';
            });
          },
        ),
        ChoiceChip(
          selected: _selectedTab == 'juries',
          label: const Text('Per Juri'),
          onSelected: (_) {
            setState(() {
              _selectedTab = 'juries';
            });
          },
        ),
      ],
    );
  }

  Widget _candidateList(List<CandidateScoreMonitoringModel> candidates) {
    if (candidates.isEmpty) {
      return const _EmptyInfo(
        icon: Icons.people_outline,
        title: 'Belum ada calon yang dimonitor.',
        subtitle: 'Calon pending dan ditolak tidak masuk monitoring nilai.',
      );
    }

    final sorted = List<CandidateScoreMonitoringModel>.from(candidates)
      ..sort((a, b) => a.completionPercentage.compareTo(b.completionPercentage));

    return Column(
      children: sorted.map((candidate) {
        final progress =
        candidate.completionPercentage.clamp(0, 100).toDouble();
        final color = _progressColor(progress);

        return Card(
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                candidate.isComplete
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                color: color,
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
                  Text(
                    '${candidate.scoredCriteriaCount}/${candidate.criteriaCount} kriteria dinilai',
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.toStringAsFixed(2)}% lengkap',
                    style: TextStyle(color: color),
                  ),
                ],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (candidate.averageScore != null)
                      Text(
                        'Rata-rata nilai: ${candidate.averageScore!.toStringAsFixed(3)}',
                      ),
                    if ((candidate.studyProgram ?? '').isNotEmpty)
                      Text('Program studi: ${candidate.studyProgram}'),
                    Text('Status calon: ${candidate.status}'),
                    const SizedBox(height: 10),
                    if (candidate.missingCriteria.isEmpty)
                      const Text(
                        'Semua kriteria sudah dinilai.',
                        style: TextStyle(color: Colors.green),
                      )
                    else ...[
                      const Text(
                        'Kriteria yang belum dinilai:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      ...candidate.missingCriteria.map(
                            (criterion) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• ${criterion.criterionCode} - ${criterion.criterionName}',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _criterionList(List<CriterionScoreMonitoringModel> criteria) {
    if (criteria.isEmpty) {
      return const _EmptyInfo(
        icon: Icons.rule_folder_outlined,
        title: 'Belum ada kriteria aktif.',
        subtitle: 'Tambahkan kriteria aktif untuk periode ini.',
      );
    }

    final sorted = List<CriterionScoreMonitoringModel>.from(criteria)
      ..sort((a, b) => a.completionPercentage.compareTo(b.completionPercentage));

    return Column(
      children: sorted.map((criterion) {
        final progress =
        criterion.completionPercentage.clamp(0, 100).toDouble();
        final color = _progressColor(progress);

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Text(
                criterion.code,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              criterion.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tipe: ${criterion.type} • Bobot: ${criterion.weight}'),
                  const SizedBox(height: 4),
                  Text(
                    '${criterion.scoredCandidateCount}/${criterion.candidateCount} calon sudah dinilai',
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.toStringAsFixed(2)}% lengkap • '
                        '${criterion.missingCandidateCount} calon belum dinilai',
                    style: TextStyle(color: color),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _juryList(List<JuryScoreMonitoringModel> juries) {
    if (juries.isEmpty) {
      return const _EmptyInfo(
        icon: Icons.groups_outlined,
        title: 'Belum ada data juri.',
        subtitle: 'Tambahkan akun juri dan pembagian kriteria terlebih dahulu.',
      );
    }

    final sorted = List<JuryScoreMonitoringModel>.from(juries)
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      children: sorted.map((jury) {
        final color = jury.isActive ? Colors.green : Colors.red;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(Icons.person_outline, color: color),
            ),
            title: Text(
              jury.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jury.email),
                  if ((jury.phone ?? '').isNotEmpty) Text(jury.phone!),
                  const SizedBox(height: 6),
                  Text(
                    'Kriteria ditugaskan: ${jury.assignedCriteriaCount}',
                  ),
                  Text(
                    'Nilai diinput: ${jury.scoreCount}',
                  ),
                ],
              ),
            ),
            trailing: Chip(
              label: Text(
                jury.isActive ? 'Aktif' : 'Nonaktif',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: color,
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _monitoringContent() {
    final data = _monitoringData;

    if (_isLoading && data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && data == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchMonitoring,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      );
    }

    if (data == null) {
      return const _EmptyInfo(
        icon: Icons.analytics_outlined,
        title: 'Belum ada data monitoring.',
        subtitle: 'Pilih periode untuk melihat monitoring nilai.',
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMonitoring,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _summaryCard(data.summary),
          const SizedBox(height: 16),
          _tabs(),
          const SizedBox(height: 12),
          if (_selectedTab == 'candidates') _candidateList(data.candidates),
          if (_selectedTab == 'criteria') _criterionList(data.criteria),
          if (_selectedTab == 'juries') _juryList(data.juries),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Nilai'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _fetchMonitoring,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _periodSelector(periodProvider),
          ),
          Expanded(
            child: _monitoringContent(),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        Icon(icon, size: 72, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}