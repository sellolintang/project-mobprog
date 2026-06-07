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
  final TextEditingController _searchController = TextEditingController();

  String _selectedStatus = 'all';

  final List<Map<String, String>> _statusFilters = const [
    {
      'value': 'all',
      'label': 'Semua',
    },
    {
      'value': 'pending',
      'label': 'Pending',
    },
    {
      'value': 'valid',
      'label': 'Valid',
    },
    {
      'value': 'invalid',
      'label': 'Ditolak',
    },
    {
      'value': 'interview_scheduled',
      'label': 'Dijadwalkan',
    },
    {
      'value': 'interviewed',
      'label': 'Wawancara',
    },
    {
      'value': 'scored',
      'label': 'Sudah Dinilai',
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
      context.read<CandidateProvider>().fetchCandidates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<CandidateModel> _filteredCandidates(List<CandidateModel> candidates) {
    final keyword = _searchController.text.trim().toLowerCase();

    final filtered = candidates.where((candidate) {
      final matchesStatus = _selectedStatus == 'all' ||
          candidate.status.toLowerCase() == _selectedStatus;

      final searchableText = [
        candidate.registrationNumber,
        candidate.fullName,
        candidate.studentNumber,
        candidate.email,
        candidate.phone ?? '',
        candidate.faculty ?? '',
        candidate.studyProgram ?? '',
        candidate.status,
        candidate.periodId.toString(),
      ].join(' ').toLowerCase();

      final matchesKeyword =
          keyword.isEmpty || searchableText.contains(keyword);

      return matchesStatus && matchesKeyword;
    }).toList();

    filtered.sort((a, b) => b.id.compareTo(a.id));

    return filtered;
  }

  int _countByStatus(List<CandidateModel> candidates, String status) {
    if (status == 'all') return candidates.length;

    return candidates
        .where((candidate) => candidate.status.toLowerCase() == status)
        .length;
  }

  void _resetFilter() {
    FocusScope.of(context).unfocus();

    setState(() {
      _searchController.clear();
      _selectedStatus = 'all';
    });
  }

  Future<void> _deleteCandidate(CandidateModel candidate) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Calon'),
          content: Text('Yakin ingin menghapus ${candidate.fullName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
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

  Widget _buildSearchAndFilter({
    required List<CandidateModel> allCandidates,
    required int filteredCount,
  }) {
    final bool isFilterActive =
        _searchController.text.trim().isNotEmpty || _selectedStatus != 'all';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Cari calon',
            hintText: 'Nama, NIM, email, nomor pendaftaran...',
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
            children: _statusFilters.map((filter) {
              final value = filter['value']!;
              final label = filter['label']!;
              final isSelected = _selectedStatus == value;
              final count = _countByStatus(allCandidates, value);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$label ($count)'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = value;
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

  Widget _buildEmptyAllCandidates() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
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

  Widget _buildEmptyFilteredCandidates() {
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
          'Data calon tidak ditemukan.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Coba ubah kata kunci pencarian atau filter status.',
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

  Widget _buildCandidateCard(CandidateModel candidate) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(candidate.status).withOpacity(0.15),
          child: Text(
            candidate.fullName.isNotEmpty
                ? candidate.fullName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: _statusColor(candidate.status),
              fontWeight: FontWeight.bold,
            ),
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
              const SizedBox(height: 4),
              Text(
                'NIM: ${candidate.studentNumber}',
                style: const TextStyle(fontSize: 12),
              ),
              if ((candidate.faculty ?? '').isNotEmpty ||
                  (candidate.studyProgram ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  [
                    candidate.faculty,
                    candidate.studyProgram,
                  ]
                      .where((item) => item != null && item.trim().isNotEmpty)
                      .join(' • '),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    label: Text(
                      _statusLabel(candidate.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _statusColor(candidate.status),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  Chip(
                    label: Text(
                      'Periode ID: ${candidate.periodId}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
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
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateProvider>();

    final List<CandidateModel> allCandidates =
    List<CandidateModel>.from(provider.candidates);

    final List<CandidateModel> filteredCandidates =
    _filteredCandidates(allCandidates);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Calon'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.fetchCandidates,
            icon: const Icon(Icons.refresh),
          ),
        ],
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

            if (allCandidates.isEmpty) {
              return _buildEmptyAllCandidates();
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _buildSearchAndFilter(
                  allCandidates: allCandidates,
                  filteredCount: filteredCandidates.length,
                ),
                const SizedBox(height: 8),

                if (filteredCandidates.isEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: _buildEmptyFilteredCandidates(),
                  )
                else
                  ...filteredCandidates.map(_buildCandidateCard),
              ],
            );
          },
        ),
      ),
    );
  }
}