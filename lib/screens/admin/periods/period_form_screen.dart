import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/period_model.dart';
import '../../../providers/period_provider.dart';

class PeriodFormScreen extends StatefulWidget {
  const PeriodFormScreen({super.key});

  @override
  State<PeriodFormScreen> createState() => _PeriodFormScreenState();
}

class _PeriodFormScreenState extends State<PeriodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();

  String _status = 'draft';
  bool _isSubmitting = false;
  PeriodModel? _period;

  final List<Map<String, String>> _statuses = const [
    {'value': 'draft', 'label': 'Draft'},
    {'value': 'registration', 'label': 'Pendaftaran'},
    {'value': 'interview', 'label': 'Wawancara'},
    {'value': 'scoring', 'label': 'Penilaian'},
    {'value': 'finished', 'label': 'Selesai'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is PeriodModel && _period == null) {
      _period = args;
      _yearController.text = args.electionYear.toString();
      _status = args.status;
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<PeriodProvider>();
    final electionYear = int.parse(_yearController.text.trim());

    bool success;

    if (_period == null) {
      success = await provider.createPeriod(
        electionYear: electionYear,
        status: _status,
      );
    } else {
      success = await provider.updatePeriod(
        id: _period!.id,
        electionYear: electionYear,
        status: _status,
      );
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Data periode berhasil disimpan.'
              : provider.errorMessage ?? 'Gagal menyimpan periode.',
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
    final isEdit = _period != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Periode' : 'Tambah Periode'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.event_note,
                        size: 64,
                        color: Color(0xFF1E3A8A),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEdit
                            ? 'Ubah Data Periode Pemilihan'
                            : 'Tambah Data Periode Pemilihan',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tahun Pemilihan',
                          hintText: 'Contoh: 2026',
                          prefixIcon: Icon(Icons.calendar_month),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tahun pemilihan wajib diisi';
                          }

                          final year = int.tryParse(value.trim());

                          if (year == null) {
                            return 'Tahun harus berupa angka';
                          }

                          if (year < 2020 || year > 2100) {
                            return 'Tahun tidak valid';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status Periode',
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                        ),
                        items: _statuses.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['value'],
                            child: Text(item['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _status = value;
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