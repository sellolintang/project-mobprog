import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/criterion_model.dart';
import '../../../providers/criterion_provider.dart';
import '../../../providers/period_provider.dart';

class CriterionFormScreen extends StatefulWidget {
  const CriterionFormScreen({super.key});

  @override
  State<CriterionFormScreen> createState() => _CriterionFormScreenState();
}

class _CriterionFormScreenState extends State<CriterionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _minScoreController = TextEditingController();
  final _maxScoreController = TextEditingController();

  int? _periodId;
  String _type = 'benefit';
  bool _isActive = true;
  bool _isSubmitting = false;
  CriterionModel? _criterion;

  final List<Map<String, String>> _types = const [
    {'value': 'benefit', 'label': 'Benefit'},
    {'value': 'cost', 'label': 'Cost'},
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<PeriodProvider>().fetchPeriods();
      context.read<CriterionProvider>().fetchCriteria();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is CriterionModel && _criterion == null) {
      _criterion = args;

      _periodId = args.periodId;
      _codeController.text = args.code;
      _nameController.text = args.name;
      _weightController.text = _toPercent(args.weight).toStringAsFixed(0);
      _minScoreController.text = args.minScore.toString();
      _maxScoreController.text = args.maxScore.toString();
      _type = args.type;
      _isActive = args.isActive;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _minScoreController.dispose();
    _maxScoreController.dispose();
    super.dispose();
  }

  double _toPercent(double weight) {
    if (weight <= 1) {
      return weight * 100;
    }

    return weight;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showMessage({
    required String message,
    required bool success,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  double _getCurrentTotalWeight({
    required int periodId,
  }) {
    final criteria = context.read<CriterionProvider>().criteria;

    return criteria.where((criterion) {
      final samePeriod = criterion.periodId == periodId;
      final differentItem =
          _criterion == null || criterion.id != _criterion!.id;

      return samePeriod && differentItem && criterion.isActive;
    }).fold<double>(
      0,
          (total, criterion) => total + _toPercent(criterion.weight),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_periodId == null) {
      _showError('Periode wajib dipilih.');
      return;
    }

    final code = _codeController.text.trim();
    final name = _nameController.text.trim();

    final weightPercent = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );

    final minScore = double.tryParse(
      _minScoreController.text.trim().replaceAll(',', '.'),
    );

    final maxScore = double.tryParse(
      _maxScoreController.text.trim().replaceAll(',', '.'),
    );

    if (weightPercent == null) {
      _showError('Bobot kriteria wajib berupa angka.');
      return;
    }

    if (weightPercent <= 0) {
      _showError('Bobot kriteria harus lebih dari 0%.');
      return;
    }

    if (weightPercent > 100) {
      _showError('Bobot satu kriteria tidak boleh lebih dari 100%.');
      return;
    }

    if (minScore == null || maxScore == null) {
      _showError('Nilai minimum dan maksimum harus berupa angka.');
      return;
    }

    if (maxScore <= minScore) {
      _showError('Nilai maksimum harus lebih besar dari nilai minimum.');
      return;
    }

    final currentTotalWeight = _getCurrentTotalWeight(
      periodId: _periodId!,
    );

    final totalAfterSave = _isActive
        ? currentTotalWeight + weightPercent
        : currentTotalWeight;

    if (totalAfterSave > 100) {
      _showError(
        'Total bobot kriteria aktif tidak boleh lebih dari 100%. '
            'Total setelah disimpan: ${totalAfterSave.toStringAsFixed(2)}%.',
      );
      return;
    }

    final weightDecimal = weightPercent / 100;

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<CriterionProvider>();

    bool success;

    if (_criterion == null) {
      success = await provider.createCriterion(
        periodId: _periodId!,
        code: code,
        name: name,
        weight: weightDecimal,
        type: _type,
        minScore: minScore,
        maxScore: maxScore,
        isActive: _isActive,
      );
    } else {
      success = await provider.updateCriterion(
        id: _criterion!.id,
        periodId: _periodId!,
        code: code,
        name: name,
        weight: weightDecimal,
        type: _type,
        minScore: minScore,
        maxScore: maxScore,
        isActive: _isActive,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    _showMessage(
      message: success
          ? 'Data kriteria berhasil disimpan.'
          : provider.errorMessage ?? 'Gagal menyimpan kriteria.',
      success: success,
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _criterion != null;
    final periodProvider = context.watch<PeriodProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kriteria' : 'Tambah Kriteria'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.rule,
                        size: 64,
                        color: Color(0xFF1E3A8A),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEdit ? 'Ubah Data Kriteria' : 'Tambah Data Kriteria',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      DropdownButtonFormField<int>(
                        initialValue: _periodId,
                        decoration: const InputDecoration(
                          labelText: 'Periode Pemilihan',
                          prefixIcon: Icon(Icons.event_note),
                          border: OutlineInputBorder(),
                        ),
                        items: periodProvider.periods.map((period) {
                          return DropdownMenuItem<int>(
                            value: period.id,
                            child: Text(
                              'Duta Kampus ${period.electionYear}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _periodId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Periode wajib dipilih';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Kode Kriteria',
                          hintText: 'Contoh: C1',
                          prefixIcon: Icon(Icons.tag),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kode kriteria wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Kriteria',
                          hintText: 'Contoh: Public Speaking',
                          prefixIcon: Icon(Icons.abc),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama kriteria wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Bobot Kriteria (%)',
                          hintText: 'Contoh: 25',
                          prefixIcon: Icon(Icons.scale),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Bobot wajib diisi';
                          }

                          final weight = double.tryParse(
                            value.trim().replaceAll(',', '.'),
                          );

                          if (weight == null) {
                            return 'Bobot harus berupa angka';
                          }

                          if (weight <= 0) {
                            return 'Bobot harus lebih dari 0';
                          }

                          if (weight > 100) {
                            return 'Maksimal 100';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(
                          labelText: 'Tipe Kriteria',
                          prefixIcon: Icon(Icons.compare_arrows),
                          border: OutlineInputBorder(),
                        ),
                        items: _types.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['value'],
                            child: Text(item['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _type = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minScoreController,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Nilai Minimum',
                                hintText: '0',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Wajib diisi';
                                }

                                final score = double.tryParse(
                                  value.trim().replaceAll(',', '.'),
                                );

                                if (score == null) {
                                  return 'Harus angka';
                                }

                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _maxScoreController,
                              keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Nilai Maksimum',
                                hintText: '100',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Wajib diisi';
                                }

                                final maxScore = double.tryParse(
                                  value.trim().replaceAll(',', '.'),
                                );

                                final minScore = double.tryParse(
                                  _minScoreController.text
                                      .trim()
                                      .replaceAll(',', '.'),
                                );

                                if (maxScore == null) {
                                  return 'Harus angka';
                                }

                                if (minScore != null && maxScore <= minScore) {
                                  return 'Harus > min';
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      SwitchListTile(
                        value: _isActive,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Kriteria Aktif'),
                        subtitle: const Text(
                          'Kriteria aktif akan dipakai dalam penilaian.',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSubmitting ? 'Menyimpan...' : 'Simpan',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}