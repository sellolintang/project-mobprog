import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/announcement_readiness_model.dart';
import '../../../models/aras_result_model.dart';
import '../../../models/period_model.dart';
import '../../../providers/aras_result_provider.dart';
import '../../../providers/period_provider.dart';
import '../../../services/announcement_service.dart';

class ArasResultListScreen extends StatefulWidget {
  const ArasResultListScreen({super.key});

  @override
  State<ArasResultListScreen> createState() => _ArasResultListScreenState();
}

class _ArasResultListScreenState extends State<ArasResultListScreen> {
  final AnnouncementService _announcementService = AnnouncementService();

  int? _selectedPeriodId;
  AnnouncementReadinessModel? _readiness;

  bool _isCheckingReadiness = false;
  bool _isPublishing = false;
  String? _announcementError;

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

        await context.read<ArasResultProvider>().fetchResults(
          periodId: _selectedPeriodId,
        );

        await _checkReadiness(showMessage: false);
      } else {
        await context.read<ArasResultProvider>().fetchResults();
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  PeriodModel? _selectedPeriod(List<PeriodModel> periods) {
    if (_selectedPeriodId == null) return null;

    try {
      return periods.firstWhere((period) => period.id == _selectedPeriodId);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Color _rankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.blueGrey;
    if (rank == 3) return Colors.brown;

    return Colors.grey;
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
      default:
        return Colors.orange;
    }
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

  void _showSnackBar(
      String message, {
        Color backgroundColor = Colors.green,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> _refreshAll({
    bool checkReadiness = true,
  }) async {
    await context.read<PeriodProvider>().fetchPeriods();

    if (!mounted) return;

    await context.read<ArasResultProvider>().fetchResults(
      periodId: _selectedPeriodId,
    );

    if (checkReadiness) {
      await _checkReadiness(showMessage: false);
    }
  }

  Future<void> _checkReadiness({
    bool showMessage = true,
  }) async {
    if (_selectedPeriodId == null) {
      _showSnackBar(
        'Pilih periode terlebih dahulu.',
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      setState(() {
        _isCheckingReadiness = true;
        _announcementError = null;
      });

      final result = await _announcementService.checkReadiness(
        _selectedPeriodId!,
      );

      if (!mounted) return;

      setState(() {
        _readiness = result;
        _isCheckingReadiness = false;
      });

      if (showMessage) {
        _showSnackBar(
          result.ready
              ? 'Data sudah siap dipublikasikan.'
              : 'Data belum siap dipublikasikan.',
          backgroundColor: result.ready ? Colors.green : Colors.orange,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCheckingReadiness = false;
        _announcementError = e.toString().replaceFirst('Exception: ', '');
      });

      if (showMessage) {
        _showSnackBar(
          _announcementError ?? 'Gagal memeriksa kesiapan.',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> _calculateAras() async {
    if (_selectedPeriodId == null) {
      _showSnackBar(
        'Pilih periode terlebih dahulu.',
        backgroundColor: Colors.red,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hitung ARAS'),
          content: const Text(
            'Yakin ingin menghitung ulang hasil ARAS untuk periode ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
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

    _showSnackBar(
      success
          ? 'Perhitungan ARAS berhasil dilakukan.'
          : provider.errorMessage ?? 'Perhitungan ARAS gagal.',
      backgroundColor: success ? Colors.green : Colors.red,
    );

    if (success) {
      await _refreshAll();
    }
  }

  Future<void> _publishAnnouncement() async {
    if (_selectedPeriodId == null) {
      _showSnackBar(
        'Pilih periode terlebih dahulu.',
        backgroundColor: Colors.red,
      );
      return;
    }

    await _checkReadiness(showMessage: false);

    if (!mounted) return;

    final readiness = _readiness;

    if (readiness == null) {
      _showSnackBar(
        'Kesiapan data belum berhasil diperiksa.',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (!readiness.ready) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Data Belum Siap'),
            content: SingleChildScrollView(
              child: _ReadinessDetailContent(readiness: readiness),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      );

      return;
    }

    final noteController = TextEditingController();

    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Publikasikan Pengumuman'),
          content: TextField(
            controller: noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Catatan pengumuman',
              hintText: 'Contoh: Selamat kepada peserta terpilih.',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, noteController.text.trim());
              },
              icon: const Icon(Icons.publish),
              label: const Text('Publish'),
            ),
          ],
        );
      },
    );

    noteController.dispose();

    if (note == null || !mounted) return;

    try {
      setState(() {
        _isPublishing = true;
        _announcementError = null;
      });

      final result = await _announcementService.publish(
        periodId: _selectedPeriodId!,
        announcementNote: note,
      );

      if (!mounted) return;

      setState(() {
        _isPublishing = false;
        if (result.readiness != null) {
          _readiness = result.readiness;
        }
      });

      _showSnackBar(result.message);

      await _refreshAll();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPublishing = false;
        _announcementError = e.toString().replaceFirst('Exception: ', '');
      });

      _showSnackBar(
        _announcementError ?? 'Gagal mempublikasikan pengumuman.',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _unpublishAnnouncement() async {
    if (_selectedPeriodId == null) {
      _showSnackBar(
        'Pilih periode terlebih dahulu.',
        backgroundColor: Colors.red,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Publikasi'),
          content: const Text(
            'Yakin ingin membatalkan publikasi hasil? '
                'Hasil tidak akan tampil di halaman publik.',
          ),
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
              child: const Text('Unpublish'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    try {
      setState(() {
        _isPublishing = true;
        _announcementError = null;
      });

      final result = await _announcementService.unpublish(_selectedPeriodId!);

      if (!mounted) return;

      setState(() {
        _isPublishing = false;
      });

      _showSnackBar(result.message);

      await _refreshAll();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPublishing = false;
        _announcementError = e.toString().replaceFirst('Exception: ', '');
      });

      _showSnackBar(
        _announcementError ?? 'Gagal membatalkan publikasi.',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _deleteResult(ArasResultModel result) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Hasil'),
          content: Text(
            'Yakin ingin menghapus hasil ${result.candidateName ?? '-'}?',
          ),
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

    final provider = context.read<ArasResultProvider>();
    final success = await provider.deleteResult(
      result.id,
      periodId: _selectedPeriodId,
    );

    if (!mounted) return;

    _showSnackBar(
      success
          ? 'Hasil ARAS berhasil dihapus.'
          : provider.errorMessage ?? 'Gagal menghapus hasil ARAS.',
      backgroundColor: success ? Colors.green : Colors.red,
    );

    if (success) {
      await _checkReadiness(showMessage: false);
    }
  }

  Widget _rankBadge(int rank) {
    return CircleAvatar(
      backgroundColor: _rankColor(rank),
      child: Text(
        rank.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _periodSelector(PeriodProvider periodProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<int>(
        value: _selectedPeriodId,
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
            _readiness = null;
            _announcementError = null;
          });

          await context.read<ArasResultProvider>().fetchResults(
            periodId: value,
          );

          await _checkReadiness(showMessage: false);
        },
      ),
    );
  }

  Widget _publicationCard(PeriodModel? selectedPeriod) {
    if (_selectedPeriodId == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Pilih periode terlebih dahulu'),
          ),
        ),
      );
    }

    final isPublished = selectedPeriod?.isResultPublished == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: isPublished ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isPublished
                        ? Icons.public
                        : Icons.visibility_off_outlined,
                    color: isPublished ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isPublished
                          ? 'Hasil Sudah Dipublikasikan'
                          : 'Hasil Belum Dipublikasikan',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (_isPublishing)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (selectedPeriod != null) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        _periodStatusLabel(selectedPeriod.status),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                      _periodStatusColor(selectedPeriod.status),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (isPublished)
                      Chip(
                        label: Text(
                          'Publish: ${_formatDate(selectedPeriod.resultPublishedAt)}',
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                if ((selectedPeriod.announcementNote ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    selectedPeriod.announcementNote!,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ],
              if (_announcementError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _announcementError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isCheckingReadiness
                        ? null
                        : () => _checkReadiness(),
                    icon: _isCheckingReadiness
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.fact_check_outlined),
                    label: const Text('Cek Kesiapan'),
                  ),
                  if (!isPublished)
                    ElevatedButton.icon(
                      onPressed: _isPublishing ? null : _publishAnnouncement,
                      icon: const Icon(Icons.publish),
                      label: const Text('Publish'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _isPublishing ? null : _unpublishAnnouncement,
                      icon: const Icon(Icons.visibility_off),
                      label: const Text('Unpublish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readinessCard() {
    final readiness = _readiness;

    if (_isCheckingReadiness && readiness == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Card(
          child: ListTile(
            leading: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text('Memeriksa kesiapan data...'),
          ),
        ),
      );
    }

    if (readiness == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        color: readiness.ready
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFFFFBEB),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: _ReadinessDetailContent(readiness: readiness),
        ),
      ),
    );
  }

  Widget _resultList(ArasResultProvider arasProvider) {
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
              context.read<ArasResultProvider>().fetchResults(
                periodId: _selectedPeriodId,
              );
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
          SizedBox(height: 90),
          Icon(
            Icons.emoji_events_outlined,
            size: 72,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada hasil ARAS.\nTekan tombol kalkulator untuk menghitung hasil.',
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
                  Text(result.registrationNumber ?? '-'),
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
  }

  @override
  Widget build(BuildContext context) {
    final arasProvider = context.watch<ArasResultProvider>();
    final periodProvider = context.watch<PeriodProvider>();
    final selectedPeriod = _selectedPeriod(periodProvider.periods);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil ARAS'),
        actions: [
          IconButton(
            onPressed:
            _isCheckingReadiness ? null : () => _checkReadiness(),
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Cek Kesiapan',
          ),
          IconButton(
            onPressed: _calculateAras,
            icon: const Icon(Icons.calculate),
            tooltip: 'Hitung ARAS',
          ),
        ],
      ),
      body: Column(
        children: [
          _periodSelector(periodProvider),
          _publicationCard(selectedPeriod),
          _readinessCard(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refreshAll(),
              child: _resultList(arasProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessDetailContent extends StatelessWidget {
  final AnnouncementReadinessModel readiness;

  const _ReadinessDetailContent({
    required this.readiness,
  });

  @override
  Widget build(BuildContext context) {
    final color = readiness.ready ? Colors.green : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              readiness.ready
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_outlined,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                readiness.ready
                    ? 'Data Siap Dipublikasikan'
                    : 'Data Belum Siap Dipublikasikan',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text('Kriteria: ${readiness.criteriaCount}'),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(
                'Kandidat layak: ${readiness.eligibleCandidateCount}',
              ),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text('Hasil ARAS: ${readiness.arasResultCount}'),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(
                'Nilai belum lengkap: ${readiness.missingScoreCount}',
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        if (readiness.warnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Catatan:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ...readiness.warnings.map(
                (warning) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(warning)),
                ],
              ),
            ),
          ),
        ],
        if (readiness.missingScoreSamples.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Contoh nilai yang belum lengkap:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ...readiness.missingScoreSamples.take(5).map(
                (sample) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${sample.candidateName} - '
                    '${sample.criterionCode} ${sample.criterionName}',
              ),
            ),
          ),
        ],
      ],
    );
  }
}