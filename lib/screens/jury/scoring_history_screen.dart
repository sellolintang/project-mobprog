import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/period_model.dart';
import '../../models/score_model.dart';
import '../../providers/period_provider.dart';
import '../../providers/score_provider.dart';

class ScoringHistoryScreen extends StatefulWidget {
  const ScoringHistoryScreen({super.key});

  @override
  State<ScoringHistoryScreen> createState() => _ScoringHistoryScreenState();
}

class _ScoringHistoryScreenState extends State<ScoringHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  int? _selectedPeriodId;
  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = const [
    {
      'value': 'all',
      'label': 'Semua',
    },
    {
      'value': 'complete',
      'label': 'Lengkap',
    },
    {
      'value': 'incomplete',
      'label': 'Belum Lengkap',
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
        // fallback
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
      await scoreProvider.fetchHistory(periodId: _selectedPeriodId!);
    }
  }

  Future<void> _refreshHistory() async {
    if (_selectedPeriodId == null) return;

    await context.read<ScoreProvider>().fetchHistory(
      periodId: _selectedPeriodId!,
    );
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

  List<ScoreCandidateModel> _filteredHistories(
      List<ScoreCandidateModel> histories,
      ) {
    final keyword = _searchController.text.trim().toLowerCase();

    final filtered = histories.where((candidate) {
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'complete' && candidate.isComplete) ||
          (_selectedFilter == 'incomplete' && !candidate.isComplete);

      final searchableText = [
        candidate.registrationNumber,
        candidate.fullName,
        candidate.studentNumber,
        candidate.studyProgram ?? '',
        candidate.candidateStatus ?? '',
      ].join(' ').toLowerCase();

      final matchesKeyword =
          keyword.isEmpty || searchableText.contains(keyword);

      return matchesFilter && matchesKeyword;
    }).toList();

    filtered.sort((a, b) {
      final aDate = DateTime.tryParse(a.lastUpdatedAt ?? '');
      final bDate = DateTime.tryParse(b.lastUpdatedAt ?? '');

      if (aDate != null && bDate != null) {
        return bDate.compareTo(aDate);
      }

      return a.fullName.toLowerCase().compareTo(
        b.fullName.toLowerCase(),
      );
    });

    return filtered;
  }

  int _countByFilter(List<ScoreCandidateModel> histories, String filter) {
    if (filter == 'complete') {
      return histories.where((item) => item.isComplete).length;
    }

    if (filter == 'incomplete') {
      return histories.where((item) => !item.isComplete).length;
    }

    return histories.length;
  }

  void _resetFilter() {
    FocusScope.of(context).unfocus();

    setState(() {
      _searchController.clear();
      _selectedFilter = 'all';
    });
  }

  Future<void> _openScoringForm(ScoreCandidateModel candidate) async {
    if (_selectedPeriodId == null) return;

    await Navigator.pushNamed(
      context,
      AppRoutes.scoringForm,
      arguments: {
        'period_id': _selectedPeriodId,
        'candidate': candidate,
      },
    );

    if (!mounted) return;

    await _refreshHistory();
  }

  Future<void> _showHistoryDetail(ScoreCandidateModel candidate) async {
    if (_selectedPeriodId == null) return;

    final provider = context.read<ScoreProvider>();

    await provider.fetchHistoryDetail(
      periodId: _selectedPeriodId!,
      candidateId: candidate.id,
    );

    if (!mounted) return;

    final detail = context.read<ScoreProvider>().historyDetail;
    final errorMessage = context.read<ScoreProvider>().errorMessage;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (bottomSheetContext) {
        if (detail == null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage ?? 'Detail riwayat tidak dapat dimuat.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(bottomSheetContext),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          );
        }

        return _HistoryDetailSheet(
          detail: detail,
          onEdit: () {
            Navigator.pop(bottomSheetContext);
            _openScoringForm(candidate);
          },
        );
      },
    );
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: DropdownButtonFormField<int>(
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

            await context.read<ScoreProvider>().fetchHistory(
              periodId: value,
            );
          },
        ),
      ),
    );
  }

  Widget _searchAndFilter({
    required List<ScoreCandidateModel> allHistories,
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
            labelText: 'Cari riwayat',
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
              final count = _countByFilter(allHistories, value);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: _selectedFilter == value,
                  label: Text('$label ($count)'),
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
                    ? 'Menampilkan $filteredCount dari ${allHistories.length} riwayat'
                    : 'Total ${allHistories.length} riwayat',
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

  Widget _historyCard(ScoreCandidateModel candidate) {
    final progress = candidate.completionPercentage.clamp(0, 100).toDouble();
    final color = _progressColor(progress);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showHistoryDetail(candidate),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: color,
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
                    if ((candidate.lastUpdatedAt ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Terakhir diubah: ${_formatDateTime(candidate.lastUpdatedAt)}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
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
                          backgroundColor: color,
                          visualDensity: VisualDensity.compact,
                        ),
                        Chip(
                          label: Text(
                            _candidateStatusLabel(candidate.candidateStatus),
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'detail') {
                    _showHistoryDetail(candidate);
                  }

                  if (value == 'edit') {
                    _openScoringForm(candidate);
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'detail',
                      child: Text('Detail Nilai'),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Ubah Nilai'),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyAllHistories() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 120),
        Icon(
          Icons.history_outlined,
          size: 72,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Text(
          'Belum ada riwayat penilaian.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'Riwayat akan muncul setelah juri menyimpan nilai calon.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _emptyFilteredHistories() {
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
          'Riwayat tidak ditemukan.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Coba ubah kata kunci pencarian atau filter riwayat.',
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

  Widget _errorView(ScoreProvider provider) {
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
          provider.errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _refreshHistory,
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

    final allHistories = List<ScoreCandidateModel>.from(
      scoreProvider.histories,
    );

    final filteredHistories = _filteredHistories(allHistories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penilaian'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshHistory,
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
              onRefresh: _refreshHistory,
              child: Builder(
                builder: (context) {
                  if (scoreProvider.isLoading && allHistories.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (scoreProvider.errorMessage != null &&
                      allHistories.isEmpty) {
                    return _errorView(scoreProvider);
                  }

                  if (allHistories.isEmpty) {
                    return _emptyAllHistories();
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _searchAndFilter(
                        allHistories: allHistories,
                        filteredCount: filteredHistories.length,
                      ),
                      const SizedBox(height: 8),
                      if (filteredHistories.isEmpty)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.62,
                          child: _emptyFilteredHistories(),
                        )
                      else
                        ...filteredHistories.map(_historyCard),
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

class _HistoryDetailSheet extends StatelessWidget {
  final ScoringHistoryDetailModel detail;
  final VoidCallback onEdit;

  const _HistoryDetailSheet({
    required this.detail,
    required this.onEdit,
  });

  Color _progressColor(double value) {
    if (value >= 100) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatScore(double? value) {
    if (value == null) return '-';

    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final candidate = detail.candidate;
    final summary = detail.summary;
    final progress = summary.completionPercentage.clamp(0, 100).toDouble();
    final color = _progressColor(progress);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.45,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(18),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Detail Nilai',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(
                  candidate?.fullName ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  [
                    candidate?.registrationNumber ?? '-',
                    candidate?.studentNumber ?? '-',
                    candidate?.studyProgram ?? '',
                  ].where((item) => item.trim().isNotEmpty).join('\n'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: summary.isComplete ? const Color(0xFFF0FDF4) : null,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(
                        summary.isComplete
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_outlined,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.isComplete
                                ? 'Penilaian Lengkap'
                                : 'Penilaian Belum Lengkap',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${summary.scoredCriteriaCount}/${summary.assignedCriteriaCount} kriteria • ${progress.toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (summary.averageScore != null)
                            Text(
                              'Rata-rata nilai: ${_formatScore(summary.averageScore)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nilai per Kriteria',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (detail.scores.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Belum ada detail nilai.'),
                ),
              )
            else
              ...detail.scores.map((score) {
                final hasScore = score.score != null;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: hasScore
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFFFFBEB),
                      child: Text(
                        score.code,
                        style: TextStyle(
                          color: hasScore
                              ? const Color(0xFF1E3A8A)
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      score.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Bobot: ${score.weight} • ${score.type} • '
                          'Rentang ${_formatScore(score.minScore)}-${_formatScore(score.maxScore)}',
                    ),
                    trailing: Text(
                      _formatScore(score.score),
                      style: TextStyle(
                        color: hasScore ? Colors.green : Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_note),
              label: const Text('Ubah Nilai'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        );
      },
    );
  }
}