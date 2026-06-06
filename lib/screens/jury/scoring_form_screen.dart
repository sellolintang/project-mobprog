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
      _periodId = args['period_id'] as int?;
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

  void _prepareControllers(List<ScoreCriterionModel> criteria) {
    for (final controller in _scoreControllers.values) {
      controller.dispose();
    }

    _scoreControllers.clear();

    for (final criterion in criteria) {
      _scoreControllers[criterion.id] = TextEditingController(
        text: criterion.score == null ? '' : criterion.score.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_periodId == null || _candidate == null) return;

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ScoreProvider>();

    final List<Map<String, dynamic>> scores = provider.criteria.map((criterion) {
      final rawValue = _scoreControllers[criterion.id]?.text.trim() ?? '0';
      final scoreValue = double.parse(rawValue.replaceAll(',', '.'));

      return {
        'criterion_id': criterion.id,
        'score': scoreValue,
      };
    }).toList();

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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScoreProvider>();

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
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
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
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        _candidate!.fullName.isNotEmpty
                            ? _candidate!.fullName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      _candidate!.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_candidate!.registrationNumber),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Kriteria Penilaian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...provider.criteria.map((criterion) {
                  final controller = _scoreControllers[criterion.id];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${criterion.code} - ${criterion.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bobot: ${criterion.weight} | Tipe: ${criterion.type}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          Text(
                            'Rentang nilai: ${criterion.minScore} - ${criterion.maxScore}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Nilai',
                              prefixIcon: Icon(Icons.edit_note),
                              border: OutlineInputBorder(),
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
                                return 'Nilai harus berada pada rentang ${criterion.minScore} - ${criterion.maxScore}';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),

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