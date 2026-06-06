import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../models/jury_model.dart';
import '../../../providers/jury_provider.dart';

class JuryListScreen extends StatefulWidget {
  const JuryListScreen({super.key});

  @override
  State<JuryListScreen> createState() => _JuryListScreenState();
}

class _JuryListScreenState extends State<JuryListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<JuryProvider>().fetchJuries();
    });
  }

  Future<void> _deleteJury(JuryModel jury) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Juri'),
          content: Text(
            'Yakin ingin menghapus atau menonaktifkan akun ${jury.name}?',
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

    final provider = context.read<JuryProvider>();
    final success = await provider.deleteJury(jury.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Data juri berhasil diproses.'
              : provider.errorMessage ?? 'Gagal menghapus juri.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _toggleStatus(JuryModel jury) async {
    final provider = context.read<JuryProvider>();
    final success = await provider.toggleStatus(jury.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Status akun juri berhasil diperbarui.'
              : provider.errorMessage ?? 'Gagal mengubah status juri.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JuryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Juri'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.juryForm);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchJuries,
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
                    onPressed: provider.fetchJuries,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              );
            }

            if (provider.juries.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.groups_outlined,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada data juri.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.juries.length,
              itemBuilder: (context, index) {
                final jury = provider.juries[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        jury.name.isNotEmpty ? jury.name[0].toUpperCase() : '?',
                      ),
                    ),
                    title: Text(
                      jury.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(jury.email),
                          if (jury.phone != null && jury.phone!.isNotEmpty)
                            Text(jury.phone!),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Chip(
                                label: Text(
                                  jury.isActive ? 'Aktif' : 'Nonaktif',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor:
                                jury.isActive ? Colors.green : Colors.grey,
                              ),
                              Chip(
                                label: Text(
                                  'Kriteria: ${jury.criteriaCount}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              if (jury.criteriaCodes.isNotEmpty)
                                Chip(
                                  label: Text(
                                    jury.criteriaCodes.join(', '),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.juryForm,
                            arguments: jury,
                          );
                        } else if (value == 'status') {
                          _toggleStatus(jury);
                        } else if (value == 'delete') {
                          _deleteJury(jury);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'status',
                            child: Text(
                              jury.isActive ? 'Nonaktifkan' : 'Aktifkan',
                            ),
                          ),
                          const PopupMenuItem(
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