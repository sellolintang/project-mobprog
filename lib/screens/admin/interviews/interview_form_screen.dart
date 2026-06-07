import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/interview_model.dart';
import '../../../providers/candidate_provider.dart';
import '../../../providers/interview_provider.dart';

class InterviewFormScreen extends StatefulWidget {
  const InterviewFormScreen({super.key});

  @override
  State<InterviewFormScreen> createState() => _InterviewFormScreenState();
}

class _InterviewFormScreenState extends State<InterviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();

  int? _candidateId;
  DateTime? _scheduledAt;
  String _status = 'scheduled';
  bool _isSubmitting = false;
  InterviewModel? _interview;

  final List<Map<String, String>> _statuses = const [
    {'value': 'scheduled', 'label': 'Terjadwal'},
    {'value': 'completed', 'label': 'Selesai'},
    {'value': 'absent', 'label': 'Tidak Hadir'},
    {'value': 'cancelled', 'label': 'Dibatalkan'},
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CandidateProvider>().fetchCandidates();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is InterviewModel && _interview == null) {
      _interview = args;
      _candidateId = args.candidateId;
      _scheduledAt = DateTime.tryParse(args.scheduledAt);
      _locationController.text = args.location ?? '';
      _status = args.status;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDate: _scheduledAt ?? DateTime.now(),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledAt == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(_scheduledAt!),
    );

    if (time == null) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_candidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calon wajib dipilih.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal dan jam wawancara wajib dipilih.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<InterviewProvider>();
    final scheduledAtText = DateFormat('yyyy-MM-dd HH:mm:ss').format(_scheduledAt!);

    bool success;

    if (_interview == null) {
      success = await provider.createInterview(
        candidateId: _candidateId!,
        scheduledAt: scheduledAtText,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        status: _status,
      );
    } else {
      success = await provider.updateInterview(
        id: _interview!.id,
        candidateId: _candidateId!,
        scheduledAt: scheduledAtText,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
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
              ? provider.successMessage ??
              (_interview == null
                  ? 'Jadwal wawancara berhasil dibuat dan email jadwal dikirim ke calon.'
                  : 'Jadwal wawancara berhasil diperbarui.')
              : provider.errorMessage ?? 'Gagal menyimpan jadwal wawancara.',
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
    final isEdit = _interview != null;
    final candidateProvider = context.watch<CandidateProvider>();

    final availableCandidates = candidateProvider.candidates.where((candidate) {
      return candidate.status == 'valid' || candidate.id == _candidateId;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Jadwal' : 'Tambah Jadwal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.event_available,
                        size: 64,
                        color: Color(0xFF1E3A8A),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEdit ? 'Ubah Jadwal Wawancara' : 'Tambah Jadwal Wawancara',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      DropdownButtonFormField<int>(
                        initialValue: _candidateId,
                        decoration: const InputDecoration(
                          labelText: 'Calon Duta Kampus',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        items: availableCandidates.map((candidate) {
                          return DropdownMenuItem<int>(
                            value: candidate.id,
                            child: Text(
                              '${candidate.registrationNumber} - ${candidate.fullName}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _candidateId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Calon wajib dipilih';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      OutlinedButton.icon(
                        onPressed: _pickSchedule,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          _scheduledAt == null
                              ? 'Pilih Tanggal dan Jam'
                              : DateFormat('dd MMM yyyy, HH:mm').format(_scheduledAt!),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi Wawancara',
                          hintText: 'Contoh: Ruang Aula Kampus',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status Jadwal',
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.save),
                        label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan'),
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