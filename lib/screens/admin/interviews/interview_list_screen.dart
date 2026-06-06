import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../models/interview_model.dart';
import '../../../providers/interview_provider.dart';
import '../../../providers/period_provider.dart';

class InterviewListScreen extends StatefulWidget {
  const InterviewListScreen({super.key});

  @override
  State<InterviewListScreen> createState() => _InterviewListScreenState();
}

class _InterviewListScreenState extends State<InterviewListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InterviewProvider>().fetchInterviews();
      context.read<PeriodProvider>().fetchPeriods();
    });
  }

  String _formatDateTime(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;

    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  String _statusLabel(String status) {
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
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'absent':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteInterview(InterviewModel interview) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Jadwal'),
          content: Text(
            'Yakin ingin menghapus jadwal ${interview.candidateName ?? '-'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final provider = context.read<InterviewProvider>();
    final success = await provider.deleteInterview(interview.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Jadwal berhasil dihapus.'
              : provider.errorMessage ?? 'Gagal menghapus jadwal.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _showGenerateDialog() async {
    final periodProvider = context.read<PeriodProvider>();

    int? periodId;
    DateTime? selectedDate;
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
    final durationController = TextEditingController(text: '15');
    final locationController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Generate Jadwal Otomatis'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: periodId,
                      decoration: const InputDecoration(
                        labelText: 'Periode',
                        border: OutlineInputBorder(),
                      ),
                      items: periodProvider.periods.map((period) {
                        return DropdownMenuItem<int>(
                          value: period.id,
                          child: Text('Duta Kampus ${period.electionYear}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          periodId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2100),
                          initialDate: DateTime.now(),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        selectedDate == null
                            ? 'Pilih Tanggal'
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: selectedTime,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Durasi per calon (menit)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Generate'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) {
      durationController.dispose();
      locationController.dispose();
      return;
    }

    if (periodId == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periode dan tanggal wajib dipilih.'),
          backgroundColor: Colors.red,
        ),
      );
      durationController.dispose();
      locationController.dispose();
      return;
    }

    final duration = int.tryParse(durationController.text.trim()) ?? 15;

    final provider = context.read<InterviewProvider>();
    final success = await provider.generateInterviews(
      periodId: periodId!,
      interviewDate: DateFormat('yyyy-MM-dd').format(selectedDate!),
      startTime:
      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
      durationMinutes: duration,
      location: locationController.text.trim().isEmpty
          ? null
          : locationController.text.trim(),
    );

    durationController.dispose();
    locationController.dispose();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Jadwal otomatis berhasil dibuat.'
              : provider.errorMessage ?? 'Gagal generate jadwal.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InterviewProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Wawancara'),
        actions: [
          IconButton(
            onPressed: _showGenerateDialog,
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Generate Otomatis',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.interviewForm);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchInterviews,
        child: Builder(
          builder: (context) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
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
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.fetchInterviews,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              );
            }

            if (provider.interviews.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.event_busy,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada jadwal wawancara.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.interviews.length,
              itemBuilder: (context, index) {
                final interview = provider.interviews[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.event_available),
                    ),
                    title: Text(
                      interview.candidateName ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatDateTime(interview.scheduledAt)),
                          Text(interview.location ?? '-'),
                          const SizedBox(height: 6),
                          Chip(
                            label: Text(
                              _statusLabel(interview.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: _statusColor(interview.status),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.interviewForm,
                            arguments: interview,
                          );
                        } else if (value == 'delete') {
                          _deleteInterview(interview);
                        }
                      },
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
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
          },
        ),
      ),
    );
  }
}