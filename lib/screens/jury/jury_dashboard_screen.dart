import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/jury_dashboard_model.dart';
import '../../models/period_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/jury_dashboard_service.dart';
import '../../services/period_service.dart';

class JuryDashboardScreen extends StatefulWidget {
  const JuryDashboardScreen({super.key});

  @override
  State<JuryDashboardScreen> createState() => _JuryDashboardScreenState();
}

class _JuryDashboardScreenState extends State<JuryDashboardScreen> {
  final PeriodService _periodService = PeriodService();
  final JuryDashboardService _juryDashboardService = JuryDashboardService();

  List<PeriodModel> _periods = [];
  int? _selectedPeriodId;
  JuryDashboardModel? _dashboard;

  bool _isLoading = false;
  bool _isLoadingPeriods = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoadingPeriods = true;
        _isLoading = true;
        _errorMessage = null;
      });

      final periods = await _periodService.getPeriods();

      periods.sort((a, b) => b.electionYear.compareTo(a.electionYear));

      final selectedPeriod = _selectDefaultPeriod(periods);

      if (!mounted) return;

      setState(() {
        _periods = periods;
        _selectedPeriodId = selectedPeriod?.id;
        _isLoadingPeriods = false;
      });

      if (selectedPeriod != null) {
        await _fetchDashboard(selectedPeriod.id);
      } else {
        setState(() {
          _isLoading = false;
          _dashboard = null;
          _errorMessage = 'Belum ada periode pemilihan.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isLoadingPeriods = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  PeriodModel? _selectDefaultPeriod(List<PeriodModel> periods) {
    if (periods.isEmpty) return null;

    PeriodModel? findByStatus(String status) {
      try {
        return periods.firstWhere(
              (period) => period.status.toLowerCase() == status,
        );
      } catch (_) {
        return null;
      }
    }

    return findByStatus('scoring') ??
        findByStatus('interview') ??
        findByStatus('registration') ??
        findByStatus('finished') ??
        findByStatus('draft') ??
        periods.first;
  }

  Future<void> _fetchDashboard(int periodId) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final dashboard = await _juryDashboardService.getSummary(
        periodId: periodId,
      );

      if (!mounted) return;

      setState(() {
        _dashboard = dashboard;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _dashboard = null;
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _refreshDashboard() async {
    if (_selectedPeriodId == null) {
      await _loadInitialData();
      return;
    }

    await _fetchDashboard(_selectedPeriodId!);
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.publicHome,
          (route) => false,
    );
  }

  Future<void> _openScoringCandidates() async {
    await Navigator.pushNamed(
      context,
      AppRoutes.scoringCandidates,
      arguments: {
        'period_id': _selectedPeriodId,
      },
    );

    if (!mounted) return;

    await _refreshDashboard();
  }

  Future<void> _openScoringHistory() async {
    await Navigator.pushNamed(
      context,
      AppRoutes.scoringHistory,
      arguments: {
        'period_id': _selectedPeriodId,
      },
    );

    if (!mounted) return;

    await _refreshDashboard();
  }

  Color _progressColor(double value) {
    if (value >= 100) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }

  String _periodStatusLabel(String status) {
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

  Color _periodStatusColor(String status) {
    switch (status) {
      case 'registration':
        return Colors.green;
      case 'interview':
        return Colors.blue;
      case 'scoring':
        return Colors.purple;
      case 'finished':
        return Colors.grey;
      case 'draft':
      default:
        return Colors.orange;
    }
  }

  PeriodModel? _selectedPeriod() {
    if (_selectedPeriodId == null) return null;

    try {
      return _periods.firstWhere((period) => period.id == _selectedPeriodId);
    } catch (_) {
      return null;
    }
  }

  Widget _periodSelector() {
    if (_isLoadingPeriods && _periods.isEmpty) {
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

    if (_periods.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.event_busy, color: Colors.orange),
          title: Text('Belum ada periode'),
          subtitle: Text('Periode pemilihan belum tersedia.'),
        ),
      );
    }

    final selectedPeriod = _selectedPeriod();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedPeriodId,
              decoration: const InputDecoration(
                labelText: 'Periode Pemilihan',
                prefixIcon: Icon(Icons.event_note),
                border: OutlineInputBorder(),
              ),
              items: _periods.map((period) {
                return DropdownMenuItem<int>(
                  value: period.id,
                  child: Text('Duta Kampus ${period.electionYear}'),
                );
              }).toList(),
              onChanged: (value) async {
                if (value == null) return;

                setState(() {
                  _selectedPeriodId = value;
                  _dashboard = null;
                  _errorMessage = null;
                });

                await _fetchDashboard(value);
              },
            ),
            if (selectedPeriod != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      _periodStatusLabel(selectedPeriod.status),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _periodStatusColor(selectedPeriod.status),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (selectedPeriod.isResultPublished)
                    const Chip(
                      label: Text('Hasil sudah dipublikasi'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(JuryDashboardSummaryModel summary) {
    final progress = summary.completionPercentage.clamp(0, 100).toDouble();
    final color = _progressColor(progress);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ringkasan Tugas Juri',
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
                        '${progress.toStringAsFixed(2)}% selesai',
                        style: TextStyle(
                          color: color,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
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
                  title: 'Kriteria',
                  value: summary.assignedCriteriaCount.toString(),
                  icon: Icons.rule,
                  color: Colors.purple,
                ),
                _MiniStatCard(
                  title: 'Calon',
                  value: summary.eligibleCandidateCount.toString(),
                  icon: Icons.people_alt,
                  color: Colors.blue,
                ),
                _MiniStatCard(
                  title: 'Selesai',
                  value: summary.completedCandidateCount.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                _MiniStatCard(
                  title: 'Belum',
                  value: summary.incompleteCandidateCount.toString(),
                  icon: Icons.warning_amber_outlined,
                  color: Colors.orange,
                ),
                _MiniStatCard(
                  title: 'Nilai',
                  value: summary.scoreRecordsCount.toString(),
                  icon: Icons.assignment_turned_in_outlined,
                  color: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _criteriaCard(List<JuryAssignedCriterionModel> criteria) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kriteria yang Ditugaskan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (criteria.isEmpty)
              const Text(
                'Belum ada kriteria yang ditugaskan untuk periode ini.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ...criteria.map((criterion) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Text(
                      criterion.code,
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    criterion.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Bobot: ${criterion.weight} • ${criterion.type} • '
                        'Nilai ${criterion.minScore.toStringAsFixed(0)}-${criterion.maxScore.toStringAsFixed(0)}',
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _candidateProgressCard(List<JuryDashboardCandidateModel> candidates) {
    final sorted = List<JuryDashboardCandidateModel>.from(candidates)
      ..sort((a, b) => a.completionPercentage.compareTo(b.completionPercentage));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Progress Calon',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _openScoringCandidates,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Lihat Semua'),
                ),
              ],
            ),
            if (sorted.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Belum ada calon yang dapat dinilai pada periode ini.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ...sorted.take(5).map((candidate) {
                final progress =
                candidate.completionPercentage.clamp(0, 100).toDouble();
                final color = _progressColor(progress);

                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: _openScoringCandidates,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Text(
                              candidate.fullName.isNotEmpty
                                  ? candidate.fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candidate.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  candidate.registrationNumber,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: progress / 100,
                                  minHeight: 7,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${candidate.scoredCriteriaCount}/${candidate.assignedCriteriaCount} kriteria • ${progress.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            candidate.isComplete
                                ? Icons.check_circle_outline
                                : Icons.edit_note,
                            color: color,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _recentScoresCard(List<JuryRecentScoreModel> scores) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Nilai Terbaru',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _openScoringHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('Riwayat'),
                ),
              ],
            ),
            if (scores.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Belum ada nilai yang diinput.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ...scores.map((score) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Text(
                      score.score.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    score.candidateName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${score.criterionCode} - ${score.criterionName}',
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _errorCard() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Card(
      color: const Color(0xFFFEF2F2),
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),
        title: const Text(
          'Dashboard Juri Gagal Dimuat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_errorMessage!),
        trailing: IconButton(
          onPressed: _loadInitialData,
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _menuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Menu Juri',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _JuryMenuCard(
          icon: Icons.assignment_ind,
          title: 'Calon yang Dinilai',
          subtitle: 'Lihat daftar calon dan lengkapi penilaian',
          onTap: _openScoringCandidates,
        ),
        _JuryMenuCard(
          icon: Icons.edit_note,
          title: 'Input Nilai',
          subtitle: 'Pilih calon dan isi nilai sesuai kriteria tugas',
          onTap: _openScoringCandidates,
        ),
        _JuryMenuCard(
          icon: Icons.history,
          title: 'Riwayat Penilaian',
          subtitle: 'Lihat nilai yang sudah diberikan',
          onTap: _openScoringHistory,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final dashboard = _dashboard;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard Juri'),
        actions: [
          IconButton(
            tooltip: 'Kunci Aplikasi',
            onPressed: () async {
              await context.read<AuthProvider>().lockApp();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                    (route) => false,
              );
            },
            icon: const Icon(Icons.lock_outline),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _refreshDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Keamanan Akun',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.securitySettings);
            },
            icon: const Icon(Icons.security),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(user?.name ?? 'Juri'),
                subtitle: Text(user?.email ?? '-'),
              ),
            ),
            const SizedBox(height: 16),
            _periodSelector(),
            const SizedBox(height: 16),
            _errorCard(),
            if (_errorMessage != null) const SizedBox(height: 16),
            if (_isLoading && dashboard == null)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Memuat dashboard juri...'),
                    ],
                  ),
                ),
              ),
            if (dashboard != null) ...[
              _summaryCard(dashboard.summary),
              const SizedBox(height: 16),
              _criteriaCard(dashboard.assignedCriteria),
              const SizedBox(height: 16),
              _candidateProgressCard(dashboard.candidates),
              const SizedBox(height: 16),
              _recentScoresCard(dashboard.recentScores),
              const SizedBox(height: 24),
            ],
            _menuSection(),
          ],
        ),
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
      width: 150,
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

class _JuryMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _JuryMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E3A8A)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}