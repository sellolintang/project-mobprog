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
  final _registrationStartController = TextEditingController();
  final _registrationEndController = TextEditingController();
  final _interviewStartController = TextEditingController();
  final _interviewEndController = TextEditingController();

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

      _registrationStartController.text = _normalizeDate(args.registrationStart);
      _registrationEndController.text = _normalizeDate(args.registrationEnd);
      _interviewStartController.text = _normalizeDate(args.interviewStart);
      _interviewEndController.text = _normalizeDate(args.interviewEnd);
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _registrationStartController.dispose();
    _registrationEndController.dispose();
    _interviewStartController.dispose();
    _interviewEndController.dispose();
    super.dispose();
  }

  String _normalizeDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final date = value.trim();

    if (date.length >= 10) {
      return date.substring(0, 10);
    }

    return date;
  }

  String? _emptyToNull(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    controller.text = _formatDate(pickedDate);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
        registrationStart: _emptyToNull(_registrationStartController.text),
        registrationEnd: _emptyToNull(_registrationEndController.text),
        interviewStart: _emptyToNull(_interviewStartController.text),
        interviewEnd: _emptyToNull(_interviewEndController.text),
      );
    } else {
      success = await provider.updatePeriod(
        id: _period!.id,
        electionYear: electionYear,
        status: _status,
        registrationStart: _emptyToNull(_registrationStartController.text),
        registrationEnd: _emptyToNull(_registrationEndController.text),
        interviewStart: _emptyToNull(_interviewStartController.text),
        interviewEnd: _emptyToNull(_interviewEndController.text),
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
          ? 'Data periode berhasil disimpan.'
          : provider.errorMessage ?? 'Gagal menyimpan periode.',
      success: success,
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  Widget _dateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'YYYY-MM-DD',
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
          onPressed: () {
            setState(() {
              controller.clear();
            });
          },
          icon: const Icon(Icons.close),
        ),
      ),
      onTap: () async {
        await _pickDate(controller);

        if (mounted) {
          setState(() {});
        }
      },
    );
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
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _status = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      _dateField(
                        controller: _registrationStartController,
                        label: 'Mulai Pendaftaran',
                        icon: Icons.date_range,
                      ),

                      const SizedBox(height: 16),

                      _dateField(
                        controller: _registrationEndController,
                        label: 'Akhir Pendaftaran',
                        icon: Icons.event_available,
                      ),

                      const SizedBox(height: 16),

                      _dateField(
                        controller: _interviewStartController,
                        label: 'Mulai Wawancara',
                        icon: Icons.record_voice_over,
                      ),

                      const SizedBox(height: 16),

                      _dateField(
                        controller: _interviewEndController,
                        label: 'Akhir Wawancara',
                        icon: Icons.event_note,
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