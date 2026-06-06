import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';

class CandidateRegistrationScreen extends StatefulWidget {
  const CandidateRegistrationScreen({super.key});

  @override
  State<CandidateRegistrationScreen> createState() =>
      _CandidateRegistrationScreenState();
}

class _CandidateRegistrationScreenState
    extends State<CandidateRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _facultyController = TextEditingController();
  final _studyProgramController = TextEditingController();
  final _semesterController = TextEditingController();
  final _visionController = TextEditingController();
  final _missionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _facultyController.dispose();
    _studyProgramController.dispose();
    _semesterController.dispose();
    _visionController.dispose();
    _missionController.dispose();
    super.dispose();
  }

  String _getErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return 'Pendaftaran gagal dikirim.';
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiClient = ApiClient();

      final response = await apiClient.dio.post(
        ApiConstants.candidateRegister,
        data: {
          'full_name': _fullNameController.text.trim(),
          'student_number': _studentNumberController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'faculty': _facultyController.text.trim(),
          'study_program': _studyProgramController.text.trim(),
          'semester': int.tryParse(_semesterController.text.trim()),
          'vision': _visionController.text.trim(),
          'mission': _missionController.text.trim(),
        },
      );

      final data = response.data;
      final responseData = data is Map ? data['data'] : null;
      final candidate = responseData is Map ? responseData['candidate'] : null;

      final registrationNumber = responseData is Map
          ? responseData['registration_number']?.toString()
          : null;

      final fullName = candidate is Map
          ? candidate['full_name']?.toString()
          : _fullNameController.text.trim();

      final email = candidate is Map
          ? candidate['email']?.toString()
          : _emailController.text.trim();

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.registrationSuccess,
        arguments: {
          'registration_number': registrationNumber ?? '-',
          'full_name': fullName ?? '-',
          'email': email ?? '-',
        },
      );
    } on DioException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat mengirim pendaftaran.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran Calon'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.app_registration,
                        size: 64,
                        color: Color(0xFF1E3A8A),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Form Pendaftaran Calon Duta Kampus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Isi data diri dengan benar. Nomor pendaftaran akan dibuat otomatis oleh sistem.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 28),

                      _sectionTitle('Data Diri'),

                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama lengkap wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _studentNumberController,
                        decoration: const InputDecoration(
                          labelText: 'NIM / Nomor Mahasiswa',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'NIM wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }

                          if (!value.contains('@')) {
                            return 'Format email tidak valid';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'No. HP',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Data Akademik'),

                      TextFormField(
                        controller: _facultyController,
                        decoration: const InputDecoration(
                          labelText: 'Fakultas',
                          prefixIcon: Icon(Icons.account_balance_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _studyProgramController,
                        decoration: const InputDecoration(
                          labelText: 'Program Studi',
                          prefixIcon: Icon(Icons.school_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _semesterController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          prefixIcon: Icon(Icons.format_list_numbered),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }

                          final semester = int.tryParse(value.trim());

                          if (semester == null) {
                            return 'Semester harus berupa angka';
                          }

                          if (semester < 1 || semester > 14) {
                            return 'Semester harus 1 sampai 14';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Visi dan Misi'),

                      TextFormField(
                        controller: _visionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Visi',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _missionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Misi',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed:
                        _isSubmitting ? null : _submitRegistration,
                        icon: _isSubmitting
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(Icons.send),
                        label: Text(
                          _isSubmitting
                              ? 'Mengirim...'
                              : 'Kirim Pendaftaran',
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