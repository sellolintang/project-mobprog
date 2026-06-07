import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/jury_model.dart';
import '../../../providers/criterion_provider.dart';
import '../../../providers/jury_provider.dart';
import '../../../providers/period_provider.dart';

class JuryFormScreen extends StatefulWidget {
  const JuryFormScreen({super.key});

  @override
  State<JuryFormScreen> createState() => _JuryFormScreenState();
}

class _JuryFormScreenState extends State<JuryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  int? _periodId;
  bool _isActive = true;
  bool _isSubmitting = false;
  JuryModel? _jury;
  final Set<int> _selectedCriteriaIds = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await context.read<PeriodProvider>().fetchPeriods();
      if (!mounted) return;

      await context.read<CriterionProvider>().fetchCriteria();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is JuryModel && _jury == null) {
      _jury = args;
      _nameController.text = args.name;
      _emailController.text = args.email;
      _phoneController.text = args.phone ?? '';
      _isActive = args.isActive;

      if (args.criteria.isNotEmpty) {
        _periodId = args.criteria.first.periodId;
        _selectedCriteriaIds
          ..clear()
          ..addAll(args.criteria.map((item) => item.id));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_periodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periode wajib dipilih.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCriteriaIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal pilih satu kriteria untuk juri.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<JuryProvider>();

    bool success;

    if (_jury == null) {
      success = await provider.createJury(
        periodId: _periodId!,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        isActive: _isActive,
        criteriaIds: _selectedCriteriaIds.toList(),
      );
    } else {
      success = await provider.updateJury(
        id: _jury!.id,
        periodId: _periodId!,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim(),
        isActive: _isActive,
        criteriaIds: _selectedCriteriaIds.toList(),
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
              ? 'Data juri berhasil disimpan.'
              : provider.errorMessage ?? 'Gagal menyimpan data juri.',
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
    final isEdit = _jury != null;
    final periodProvider = context.watch<PeriodProvider>();
    final criterionProvider = context.watch<CriterionProvider>();

    final availableCriteria = criterionProvider.criteria.where((criterion) {
      if (_periodId == null) return false;
      return criterion.periodId == _periodId;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Juri' : 'Tambah Juri'),
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
                        Icons.groups,
                        size: 64,
                        color: Color(0xFF1E3A8A),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEdit ? 'Ubah Data Juri' : 'Tambah Akun Juri',
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
                            child: Text('Duta Kampus ${period.electionYear}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _periodId = value;
                            _selectedCriteriaIds.clear();
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
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Juri',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama juri wajib diisi';
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
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: isEdit
                              ? 'Password Baru (opsional)'
                              : 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final password = value?.trim() ?? '';

                          if (!isEdit && password.isEmpty) {
                            return 'Password wajib diisi';
                          }

                          if (password.isNotEmpty && password.length < 6) {
                            return 'Password minimal 6 karakter';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      SwitchListTile(
                        value: _isActive,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Akun Aktif'),
                        subtitle: const Text(
                          'Akun aktif dapat digunakan juri untuk login.',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Kriteria yang Ditugaskan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (_periodId == null)
                        const Text(
                          'Pilih periode terlebih dahulu untuk menampilkan kriteria.',
                          style: TextStyle(color: Colors.black54),
                        )
                      else if (criterionProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (availableCriteria.isEmpty)
                          const Text(
                            'Belum ada kriteria pada periode ini.',
                            style: TextStyle(color: Colors.black54),
                          )
                        else
                          Column(
                            children: availableCriteria.map((criterion) {
                              final selected =
                              _selectedCriteriaIds.contains(criterion.id);

                              return CheckboxListTile(
                                value: selected,
                                title: Text('${criterion.code} - ${criterion.name}'),
                                subtitle: Text(
                                  'Bobot: ${criterion.weight} | ${criterion.type}',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedCriteriaIds.add(criterion.id);
                                    } else {
                                      _selectedCriteriaIds.remove(criterion.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
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