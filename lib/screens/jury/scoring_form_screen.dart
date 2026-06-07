import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/score_model.dart';
import '../../providers/score_provider.dart';

class ScoringFormScreen extends StatefulWidget {
  const ScoringFormScreen({super.key});

  @override
  State<ScoringFormScreen> createState() => _ScoringFormScreenState();
}

class _ScoringFormScreenState extends State<ScoringFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, TextEditingController> _scoreControllers = {};

  int? _periodId;
  ScoreCandidateModel? _candidate;

  bool _isSubmitting = false;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasLoaded) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _periodId = int.tryParse(args['period_id'].toString());

      final candidateArg = args['candidate'];
      if (candidateArg is ScoreCandidateModel) {
        _candidate = candidateArg;
      }
    }

    if (_periodId != null && _candidate != null) {
      _hasLoaded = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final provider = context.read<ScoreProvider>();

        await provider.fetchScoringForm(
          periodId: _periodId!,
          candidateId: _candidate!.id,
        );

        if (!mounted) return;

        _prepareControllers(provider.criteria);
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _prepareControllers(List<ScoreCriterionModel> criteria) {
    for (final controller in _scoreControllers.values) {
      controller.dispose();
    }

    _scoreControllers.clear();

    for (final criterion in criteria) {
      _scoreControllers[criterion.id] = TextEditingController(
        text: criterion.score == null
            ? ''
            : _formatScoreValue(criterion.score!),
      );
    }
  }

  String _formatScoreValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toString();
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

  Color _progressColor(double value) {
    if (value >= 100) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }

  String _criterionTypeLabel(String type) {
    switch (type) {
      case 'benefit':
        return 'Benefit';
      case 'cost':
        return 'Cost';
      default:
        return type;
    }
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
      default:
        return status ?? '-';
    }
  }

  Future<void> _submit() async {
    if (_periodId == null || _candidate == null) return;
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ScoreProvider>();

    final scores = provider.criteria.map((criterion) {
      final rawValue = _scoreControllers[criterion.id]?.text.trim() ?? '0';
      final scoreValue = double.parse(rawValue.replaceAll(',', '.'));

      return {
        'criterion_id': criterion.id,
        'score': scoreValue,
      };
    }).toList();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Simpan Nilai'),
          content: Text(
            'Yakin ingin menyimpan nilai untuk ${_candidate!.fullName}? '
                'Nilai yang sudah ada akan diperbarui.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    final success = await provider.saveScores(
      periodId: _periodId!,
      candidateId: _candidate!.id,
      candidateName: _candidate!.fullName,
      scores: scores,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Nilai berhasil disimpan.'
              : provider.errorMessage ?? 'Gagal menyimpan nilai.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  Widget _candidateCard(ScoringFormCandidateModel? detail) {
    final candidateName = detail?.fullName ?? _candidate?.fullName ?? '-';
    final registrationNumber =
        detail?.registrationNumber ?? _candidate?.registrationNumber ?? '-';
    final studentNumber = detail?.studentNumber ?? _candidate?.studentNumber ?? '-';
    final studyProgram = detail?.studyProgram ?? _candidate?.studyProgram;
    final status = detail?.status ?? _candidate?.candidateStatus;
    final scheduledAt = detail?.scheduledAt ?? _candidate?.scheduledAt;
    final location = detail?.location ?? _candidate?.location;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Text(
                candidateName.isNotEmpty ? candidateName[0].toUpperCase() : '?',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidateName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(registrationNumber),
                  Text('NIM: $studentNumber'),
                  if ((studyProgram ?? '').isNotEmpty) Text(studyProgram!),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(_candidateStatusLabel(status)),
                        visualDensity: VisualDensity.compact,
                      ),
                      if ((scheduledAt ?? '').isNotEmpty)
                        Chip(
                          label: Text(_formatDateTime(scheduledAt)),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  if ((location ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Lokasi wawancara: $location'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(ScoringFormSummaryModel summary) {
    final progress = summary.completionPercentage.clamp(0, 100).toDouble();
    final color = _progressColor(progress);

    return Card(
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
                    : Icons.edit_note,
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
                    '${summary.scoredCriteriaCount}/${summary.assignedCriteriaCount} kriteria terisi • ${progress.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (summary.averageScore != null)
                    Text(
                      'Rata-rata nilai: ${summary.averageScore!.toStringAsFixed(2)}',
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

  Widget _criterionCard(ScoreCriterionModel criterion) {
    final controller = _scoreControllers[criterion.id];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        criterion.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bobot: ${criterion.weight} • ${_criterionTypeLabel(criterion.type)}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'Rentang nilai: ${_formatScoreValue(criterion.minScore)} - ${_formatScoreValue(criterion.maxScore)}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller,
              enabled: !_isSubmitting,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Nilai ${criterion.code}',
                hintText:
                '${_formatScoreValue(criterion.minScore)} - ${_formatScoreValue(criterion.maxScore)}',
                prefixIcon: const Icon(Icons.edit_note),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nilai wajib diisi';
                }

                final score = double.tryParse(
                  value.trim().replaceAll(',', '.'),
                );

                if (score == null) {
                  return 'Nilai harus berupa angka';
                }

                if (score < criterion.minScore ||
                    score > criterion.maxScore) {
                  return 'Nilai harus berada pada rentang ${_formatScoreValue(criterion.minScore)} - ${_formatScoreValue(criterion.maxScore)}';
                }

                return null;
              },
            ),
            if (criterion.updatedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Terakhir diubah: ${_formatDateTime(criterion.updatedAt)}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorView(ScoreProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          provider.errorMessage ?? 'Gagal memuat form penilaian.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              if (_periodId == null || _candidate == null) return;

              provider.fetchScoringForm(
                periodId: _periodId!,
                candidateId: _candidate!.id,
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScoreProvider>();
    final formData = provider.scoringForm;

    if (_periodId == null || _candidate == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Input Nilai'),
        ),
        body: const Center(
          child: Text('Data calon tidak ditemukan.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Nilai'),
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && formData == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null && formData == null) {
            return _errorView(provider);
          }

          if (provider.criteria.isEmpty) {
            return const Center(
              child: Text('Belum ada kriteria yang ditugaskan.'),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _candidateCard(formData?.candidate),
                const SizedBox(height: 12),
                if (formData != null) _summaryCard(formData.summary),
                const SizedBox(height: 20),
                const Text(
                  'Kriteria Penilaian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.criteria.map(_criterionCard),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSubmitting ? 'Menyimpan...' : 'Simpan Nilai',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}