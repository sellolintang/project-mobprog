import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
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

  static const int _maxPhotoSizeBytes = 2 * 1024 * 1024;
  static const int _maxCvSizeBytes = 5 * 1024 * 1024;

  PlatformFile? _photoFile;
  PlatformFile? _cvFile;

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

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }

    return '$bytes B';
  }

  void _showSnackBar(
      String message, {
        Color backgroundColor = Colors.red,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  String _getErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      final errors = data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;

        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }

        return firstValue.toString();
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Koneksi ke server terlalu lama.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server. Pastikan backend Laravel berjalan.';
    }

    return 'Pendaftaran gagal dikirim.';
  }

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;

      if (file.size > _maxPhotoSizeBytes) {
        _showSnackBar('Ukuran foto maksimal 2 MB.');
        return;
      }

      if (file.bytes == null) {
        _showSnackBar('File foto gagal dibaca. Silakan pilih ulang.');
        return;
      }

      setState(() {
        _photoFile = file;
      });
    } catch (_) {
      _showSnackBar('Gagal memilih foto.');
    }
  }

  Future<void> _pickCv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;

      if (file.size > _maxCvSizeBytes) {
        _showSnackBar('Ukuran CV maksimal 5 MB.');
        return;
      }

      if (file.bytes == null) {
        _showSnackBar('File CV gagal dibaca. Silakan pilih ulang.');
        return;
      }

      setState(() {
        _cvFile = file;
      });
    } catch (_) {
      _showSnackBar('Gagal memilih CV.');
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_photoFile == null) {
      _showSnackBar('Foto wajib diunggah.');
      return;
    }

    if (_cvFile == null) {
      _showSnackBar('CV wajib diunggah.');
      return;
    }

    final photoBytes = _photoFile!.bytes;
    final cvBytes = _cvFile!.bytes;

    if (photoBytes == null) {
      _showSnackBar('File foto belum berhasil dibaca. Silakan pilih ulang.');
      return;
    }

    if (cvBytes == null) {
      _showSnackBar('File CV belum berhasil dibaca. Silakan pilih ulang.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiClient = ApiClient();

      final semester = int.tryParse(_semesterController.text.trim());

      final formData = FormData.fromMap({
        'full_name': _fullNameController.text.trim(),
        'student_number': _studentNumberController.text.trim(),
        'email': _emailController.text.trim(),

        if (_trimOrNull(_phoneController.text) != null)
          'phone': _trimOrNull(_phoneController.text),

        if (_trimOrNull(_facultyController.text) != null)
          'faculty': _trimOrNull(_facultyController.text),

        if (_trimOrNull(_studyProgramController.text) != null)
          'study_program': _trimOrNull(_studyProgramController.text),

        if (semester != null) 'semester': semester,

        if (_trimOrNull(_visionController.text) != null)
          'vision': _trimOrNull(_visionController.text),

        if (_trimOrNull(_missionController.text) != null)
          'mission': _trimOrNull(_missionController.text),

        'photo_file': MultipartFile.fromBytes(
          photoBytes,
          filename: _photoFile!.name,
        ),

        'cv_file': MultipartFile.fromBytes(
          cvBytes,
          filename: _cvFile!.name,
        ),
      });

      final response = await apiClient.dio.post(
        ApiConstants.candidateRegister,
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {
            'Accept': 'application/json',
          },
        ),
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
      _showSnackBar(_getErrorMessage(e));
    } catch (_) {
      _showSnackBar('Terjadi kesalahan saat mengirim pendaftaran.');
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

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !_isSubmitting,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
        alignLabelWithHint: maxLines > 1,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _fileUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required PlatformFile? file,
    required VoidCallback onPick,
  }) {
    final hasFile = file != null;

    return InkWell(
      onTap: _isSubmitting ? null : onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasFile ? Colors.green : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(12),
          color: hasFile ? Colors.green.shade50 : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              hasFile ? Colors.green.shade100 : Colors.blue.shade50,
              child: Icon(
                hasFile ? Icons.check_circle_outline : icon,
                color: hasFile ? Colors.green.shade700 : Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: hasFile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatFileSize(file.size),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _isSubmitting ? null : onPick,
              child: Text(hasFile ? 'Ganti' : 'Pilih'),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? _semesterValidator(String? value) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran Calon Duta PNJ'),
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
                        'Form Pendaftaran Calon Duta PNJ',
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

                      _textField(
                        controller: _fullNameController,
                        label: 'Nama Lengkap',
                        icon: Icons.person_outline,
                        validator: (value) => _requiredValidator(
                          value,
                          'Nama lengkap wajib diisi',
                        ),
                      ),
                      const SizedBox(height: 16),

                      _textField(
                        controller: _studentNumberController,
                        label: 'NIM / Nomor Mahasiswa',
                        icon: Icons.badge_outlined,
                        validator: (value) => _requiredValidator(
                          value,
                          'NIM wajib diisi',
                        ),
                      ),
                      const SizedBox(height: 16),

                      _textField(
                        controller: _emailController,
                        label: 'Email Akademik',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 16),

                      _textField(
                        controller: _phoneController,
                        label: 'No. HP',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Data Akademik'),

                      _textField(
                        controller: _facultyController,
                        label: 'Jurusan',
                        icon: Icons.account_balance_outlined,
                      ),
                      const SizedBox(height: 16),

                      _textField(
                        controller: _studyProgramController,
                        label: 'Program Studi',
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 16),

                      _textField(
                        controller: _semesterController,
                        label: 'Semester',
                        icon: Icons.format_list_numbered,
                        keyboardType: TextInputType.number,
                        validator: _semesterValidator,
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Visi dan Misi'),

                      _textField(
                        controller: _visionController,
                        label: 'Visi',
                        icon: Icons.visibility_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      _textField(
                        controller: _missionController,
                        label: 'Misi',
                        icon: Icons.flag_outlined,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Berkas Pendaftaran'),

                      _fileUploadCard(
                        title: 'Upload Foto',
                        subtitle:
                        'Format JPG, JPEG, PNG, atau WEBP. Maksimal 2 MB.',
                        icon: Icons.image_outlined,
                        file: _photoFile,
                        onPick: _pickPhoto,
                      ),
                      const SizedBox(height: 12),

                      _fileUploadCard(
                        title: 'Upload CV',
                        subtitle:
                        'Format PDF, DOC, atau DOCX. Maksimal 5 MB.',
                        icon: Icons.description_outlined,
                        file: _cvFile,
                        onPick: _pickCv,
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