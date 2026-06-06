import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../models/criterion_model.dart';
import '../../../providers/criterion_provider.dart';

class CriterionListScreen extends StatefulWidget {
  const CriterionListScreen({super.key});

  @override
  State<CriterionListScreen> createState() => _CriterionListScreenState();
}

class _CriterionListScreenState extends State<CriterionListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CriterionProvider>().fetchCriteria();
    });
  }

  Future<void> _deleteCriterion(CriterionModel criterion) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Kriteria'),
          content: Text('Yakin ingin menghapus kriteria ${criterion.name}?'),
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

    final provider = context.read<CriterionProvider>();
    final success = await provider.deleteCriterion(criterion.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Kriteria berhasil dihapus.'
              : provider.errorMessage ?? 'Gagal menghapus kriteria.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Color _typeColor(String type) {
    return type == 'benefit' ? Colors.green : Colors.orange;
  }

  String _typeLabel(String type) {
    return type == 'benefit' ? 'Benefit' : 'Cost';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CriterionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kriteria Penilaian'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.criterionForm);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchCriteria,
        child: Builder(
          builder: (context) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
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
                    onPressed: provider.fetchCriteria,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              );
            }

            if (provider.criteria.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.rule_folder_outlined,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada data kriteria.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.criteria.length,
              itemBuilder: (context, index) {
                final criterion = provider.criteria[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(criterion.code),
                    ),
                    title: Text(
                      criterion.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(
                            label: Text(
                              _typeLabel(criterion.type),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: _typeColor(criterion.type),
                          ),
                          Chip(
                            label: Text(
                              'Bobot: ${criterion.weight}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Chip(
                            label: Text(
                              criterion.isActive ? 'Aktif' : 'Nonaktif',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.criterionForm,
                            arguments: criterion,
                          );
                        } else if (value == 'delete') {
                          _deleteCriterion(criterion);
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