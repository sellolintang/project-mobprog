import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/aras_result_model.dart';
import '../../providers/aras_result_provider.dart';

class PublicResultScreen extends StatefulWidget {
  const PublicResultScreen({super.key});

  @override
  State<PublicResultScreen> createState() => _PublicResultScreenState();
}

class _PublicResultScreenState extends State<PublicResultScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ArasResultProvider>().fetchPublicResults();
    });
  }

  Future<void> _refreshResults() {
    return context.read<ArasResultProvider>().fetchPublicResults();
  }

  Color _rankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.blueGrey;
    if (rank == 3) return Colors.brown;
    return Colors.grey;
  }

  Widget _rankBadge(int rank) {
    return CircleAvatar(
      backgroundColor: _rankColor(rank),
      child: Text(
        rank.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _resultCard(ArasResultModel result) {
    return Card(
      child: ListTile(
        leading: _rankBadge(result.finalRank),
        title: Text(
          result.candidateName ?? '-',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.registrationNumber ?? '-'),
              if ((result.studyProgram ?? '').isNotEmpty)
                Text(result.studyProgram ?? '-'),
              const SizedBox(height: 6),
              Text(
                'Utility Score: ${result.utilityScore.toStringAsFixed(6)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Hasil Ranking Duta Kampus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Ranking dihitung berdasarkan metode ARAS dari nilai juri dan bobot kriteria.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _resultBody(ArasResultProvider resultProvider) {
    if (resultProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (resultProvider.errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            resultProvider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshResults,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      );
    }

    if (resultProvider.results.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 90),
          Icon(
            Icons.emoji_events_outlined,
            size: 72,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Hasil pemilihan belum tersedia.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Hasil akan tampil setelah admin mempublikasikan pengumuman.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshResults,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: resultProvider.results.length,
        itemBuilder: (context, index) {
          return _resultCard(resultProvider.results[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultProvider = context.watch<ArasResultProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Pemilihan'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshResults,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _headerCard(),
          Expanded(
            child: _resultBody(resultProvider),
          ),
        ],
      ),
    );
  }
}