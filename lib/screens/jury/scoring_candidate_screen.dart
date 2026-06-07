import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/period_model.dart';
import '../../models/score_model.dart';
import '../../providers/period_provider.dart';
import '../../providers/score_provider.dart';

class ScoringCandidateScreen extends StatefulWidget {
  const ScoringCandidateScreen({super.key});

  @override
  State<ScoringCandidateScreen> createState() => _ScoringCandidateScreenState();
}

class _ScoringCandidateScreenState extends State<ScoringCandidateScreen> {
  final TextEditingController _searchController = TextEditingController();

  int? _selectedPeriodId;
  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = const [
    {
      'value': 'all',
      'label': 'Semua',
    },
    {
      'value': 'incomplete',
      'label': 'Belum Lengkap',
    },
    {
      'value': 'complete',
      'label': 'Lengkap',
    },
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int? _getArgumentPeriodId() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map && args['period_id'] != null) {
      return int.tryParse(args['period_id'].toString());
    }

    return null;
  }

  PeriodModel? _selectDefaultPeriod(List<PeriodModel> periods) {
    if (periods.isEmpty) return null;

    final sortedPeriods = List<PeriodModel>.from(periods)
      ..sort((a, b) => b.electionYear.compareTo(a.electionYear));

    final argumentPeriodId = _getArgumentPeriodId();

    if (argumentPeriodId != null) {
      try {
        return sortedPeriods.firstWhere(
              (period) => period.id == argumentPeriodId,
        );
      } catch (_) {
        // fallback ke status prioritas
      }
    }

    PeriodModel? findByStatus(String status) {
      try {
        return sortedPeriods.firstWhere(
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
        sortedPeriods.first;
  }

  Future<void> _loadInitialData() async {
    final periodProvider = context.read<PeriodProvider>();
    final scoreProvider = context.read<ScoreProvider>();

    await periodProvider.fetchPeriods();

    if (!mounted) return;

    final defaultPeriod = _selectDefaultPeriod(periodProvider.periods);
    final argumentPeriodId = _getArgumentPeriodId();

    setState(() {
      _selectedPeriodId = defaultPeriod?.id ?? argumentPeriodId;
    });

    if (_selectedPeriodId != null) {
      await scoreProvider.fetchCandidates(periodId: _selectedPeriodId!);
    }
  }

  Future<void> _refreshCandidates() async {
    if (_selectedPeriodId == null) return;

    await context.read<ScoreProvider>().fetchCandidates(
      periodId: _selectedPeriodId!,
    );
  }

  PeriodModel? _selectedPeriod(List<PeriodModel> periods) {
    if (_selectedPeriodId == null) return null;

    try {
      return periods.firstWhere((period) => period.id == _selectedPeriodId);
    } catch (_) {
      return null;
    }
  }

  bool _isResultPublished(List<PeriodModel> periods) {
    final period = _selectedPeriod(periods);
    return period?.isResultPublished == true;
  }

  Color _progressColor(double value) {
    if (value >= 100) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return '-';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String _candidateStatusLabel(String? status) {
    switch (status) {
      case 'valid':
        return 'Valid';
      case 'interview_scheduled':
        return 'Dijadwalkan';
      case 'interviewed':
        return 'Wawancara';
      case 'scored':
        return 'Sudah Dinilai';
      case 'pending':
        return 'Pending';
      case 'invalid':
        return 'Ditolak';
      default:
        return status ?? '-';
    }
  }

  String _interviewStatusLabel(String? status) {
    switch (status) {
      case 'scheduled':
        return 'Terjadwal';
      case 'completed':
        return 'Selesai';
      case 'absent':
        return 'Tidak Hadir';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status ?? '-';
    }
  }

  Color _interviewStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'scheduled':
        return Colors.blue;
      case 'absent':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  List<ScoreCandidateModel> _filteredCandidates(
      List<ScoreCandidateModel> candidates,
      ) {
    final keyword = _searchController.text.trim().toLowerCase();

    final filtered = candidates.where((candidate) {
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'complete' && candidate.isComplete) ||
          (_selectedFilter == 'incomplete' && !candidate.isComplete);

      final searchableText = [
        candidate.registrationNumber,
        candidate.fullName,
        candidate.studentNumber,
        candidate.studyProgram ?? '',
        candidate.candidateStatus ?? '',
        candidate.interviewStatus ?? '',
        candidate.location ?? '',
      ].join(' ').toLowerCase();

      final matchesKeyword =
          keyword.isEmpty || searchableText.contains(keyword);

      return matchesFilter && matchesKeyword;
    }).toList();

    filtered.sort((a, b) {
      if (a.isComplete != b.isComplete) {
        return a.isComplete ? 1 : -1;
      }

      return a.fullName.toLowerCase().compareTo(
        b.fullName.toLowerCase(),
      );
    });

    return filtered;
  }

  int _countByFilter(List<ScoreCandidateModel> candidates, String filter) {
    if (filter == 'complete') {
      return candidates.where((candidate) => candidate.isComplete).length;
    }

    if (filter == 'incomplete') {
      return candidates.where((candidate) => !candidate.isComplete).length;
    }

    return candidates.length;
  }

  void _resetFilter() {
    FocusScope.of(context).unfocus();

    setState(() {
      _searchController.clear();
      _selectedFilter = 'all';
    });
  }

  Future<void> _openScoringForm(
      ScoreCandidateModel candidate,
      bool isPublished,
      ) async {
    if (_selectedPeriodId == null) return;

    if (isPublished) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hasil sudah dipublikasikan. Penilaian tidak dapat diubah.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await Navigator.pushNamed(
      context,
      AppRoutes.scoringForm,
      arguments: {
        'period_id': _selectedPeriodId,
        'candidate': candidate,
      },
    );

    if (!mounted) return;

    await _refreshCandidates();
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
          subtitle: Text('Periode pemilihan belum tersedia.'),
        ),
      );
    }

    final sortedPeriods = List<PeriodModel>.from(periodProvider.periods)
      ..sort((a, b) => b.electionYear.compareTo(a.electionYear));

    final selectedPeriod = _selectedPeriod(sortedPeriods);

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
              items: sortedPeriods.map((period) {
                return DropdownMenuItem<int>(
                  value: period.id,
                  child: Text('Duta Kampus ${period.electionYear}'),
                );
              }).toList(),
              onChanged: (value) async {
                if (value == null) return;

                setState(() {
                  _selectedPeriodId = value;
                  _selectedFilter = 'all';
                  _searchController.clear();
                });

                await context.read<ScoreProvider>().fetchCandidates(
                  periodId: value,
                );
              },
            ),
            if (selectedPeriod != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text('Status: ${selectedPeriod.status}'),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (selectedPeriod.isResultPublished)
                    const Chip(
                      label: Text('Hasil sudah dipublikasi'),
                      backgroundColor: Color(0xFFFFE4E6),
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

  Widget _searchAndFilter({
    required List<ScoreCandidateModel> allCandidates,
    required int filteredCount,
  }) {
    final isFilterActive =
        _searchController.text.trim().isNotEmpty || _selectedFilter != 'all';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Cari calon',
            hintText: 'Nama, NIM, nomor pendaftaran, prodi...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.trim().isNotEmpty
                ? IconButton(
              tooltip: 'Hapus pencarian',
              onPressed: () {
                _searchController.clear();
                FocusScope.of(context).unfocus();
              },
              icon: const Icon(Icons.close),
            )
                : null,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((filter) {
              final value = filter['value']!;
              final label = filter['label']!;
              final count = _countByFilter(allCandidates, value);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$label ($count)'),
                  selected: _selectedFilter == value,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                isFilterActive
                    ? 'Menampilkan $filteredCount dari ${allCandidates.length} calon'
                    : 'Total ${allCandidates.length} calon',
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isFilterActive)
              TextButton.icon(
                onPressed: _resetFilter,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _publishedWarning() {
    return const Card(
      color: Color(0xFFFFFBEB),
      child: ListTile(
        leading: Icon(
          Icons.lock_outline,
          color: Colors.orange,
        ),
        title: Text(
          'Penilaian Dikunci',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Hasil periode ini sudah dipublikasikan. Juri hanya dapat melihat data, tidak dapat mengubah nilai.',
        ),
      ),
    );
  }

  Widget _candidateCard(
      ScoreCandidateModel candidate,
      bool isPublished,
      ) {
    final progress = candidate.completionPercentage.clamp(0, 100).toDouble();
    final progressColor = _progressColor(progress);
    final interviewColor = _interviewStatusColor(candidate.interviewStatus);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openScoringForm(candidate, isPublished),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: progressColor.withOpacity(0.15),
                child: Text(
                  candidate.fullName.isNotEmpty
                      ? candidate.fullName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: progressColor,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.registrationNumber,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      'NIM: ${candidate.studentNumber}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    if ((candidate.studyProgram ?? '').isNotEmpty)
                      Text(
                        candidate.studyProgram!,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${candidate.scoredCriteriaCount}/${candidate.assignedCriteriaCount} kriteria • ${progress.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (candidate.averageScore != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Rata-rata nilai: ${candidate.averageScore!.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(
                          label: Text(
                            candidate.isComplete ? 'Lengkap' : 'Belum Lengkap',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: progressColor,
                          visualDensity: VisualDensity.compact,
                        ),
                        Chip(
                          label: Text(
                            _candidateStatusLabel(candidate.candidateStatus),
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        if (candidate.interviewStatus != null)
                          Chip(
                            label: Text(
                              _interviewStatusLabel(candidate.interviewStatus),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: interviewColor,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    if ((candidate.scheduledAt ?? '').isNotEmpty ||
                        (candidate.location ?? '').isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((candidate.scheduledAt ?? '').isNotEmpty)
                              Text(
                                'Jadwal: ${_formatDateTime(candidate.scheduledAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            if ((candidate.location ?? '').isNotEmpty)
                              Text(
                                'Lokasi: ${candidate.location}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isPublished
                    ? Icons.lock_outline
                    : candidate.isComplete
                    ? Icons.check_circle_outline
                    : Icons.edit_note,
                color: isPublished ? Colors.grey : progressColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyAllCandidates() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
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
        SizedBox(height: 8),
        Text(
          'Pastikan calon sudah valid/wawancara dan juri sudah mendapat kriteria penilaian.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _emptyFilteredCandidates() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(
          Icons.search_off,
          size: 72,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        const Text(
          'Calon tidak ditemukan.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Coba ubah kata kunci pencarian atau filter status penilaian.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: _resetFilter,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filter'),
          ),
        ),
      ],
    );
  }

  Widget _errorView(ScoreProvider scoreProvider) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
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
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _refreshCandidates,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();
    final scoreProvider = context.watch<ScoreProvider>();

    final allCandidates = List<ScoreCandidateModel>.from(
      scoreProvider.candidates,
    );

    final filteredCandidates = _filteredCandidates(allCandidates);
    final isPublished = _isResultPublished(periodProvider.periods);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calon yang Dinilai'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshCandidates,
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
            child: RefreshIndicator(
              onRefresh: _refreshCandidates,
              child: Builder(
                builder: (context) {
                  if (scoreProvider.isLoading && allCandidates.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (scoreProvider.errorMessage != null) {
                    return _errorView(scoreProvider);
                  }

                  if (allCandidates.isEmpty) {
                    return _emptyAllCandidates();
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      if (isPublished) ...[
                        _publishedWarning(),
                        const SizedBox(height: 12),
                      ],
                      _searchAndFilter(
                        allCandidates: allCandidates,
                        filteredCount: filteredCandidates.length,
                      ),
                      const SizedBox(height: 8),
                      if (filteredCandidates.isEmpty)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.62,
                          child: _emptyFilteredCandidates(),
                        )
                      else
                        ...filteredCandidates.map(
                              (candidate) => _candidateCard(
                            candidate,
                            isPublished,
                          ),
                        ),
                    ],
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