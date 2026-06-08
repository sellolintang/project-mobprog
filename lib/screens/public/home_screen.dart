import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF1E3A8A),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFEFF6FF),
              child: Icon(icon, color: const Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFF1E3A8A),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Card(
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Duta PNJ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 56,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pemilihan Duta PNJ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aplikasi mobile untuk pendaftaran calon, validasi berkas, penilaian juri, dan perhitungan ranking menggunakan metode ARAS.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton.icon(
                //     onPressed: () {
                //       Navigator.pushNamed(
                //         context,
                //         AppRoutes.candidateRegistration,
                //       );
                //     },
                //     icon: const Icon(Icons.app_registration),
                //     label: const Text('Daftar Sekarang'),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white,
                //       foregroundColor: const Color(0xFF1E3A8A),
                //       padding: const EdgeInsets.symmetric(vertical: 14),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          _sectionTitle('Menu Publik', Icons.apps),

          _menuCard(
            icon: Icons.app_registration,
            title: 'Pendaftaran Calon',
            subtitle: 'Isi formulir dan unggah berkas pendaftaran',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.candidateRegistration);
            },
          ),
          _menuCard(
            icon: Icons.emoji_events,
            title: 'Hasil Pemilihan',
            subtitle: 'Lihat hasil ranking Duta Kampus yang sudah dipublikasikan',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.publicResult);
            },
          ),
          _menuCard(
            icon: Icons.login,
            title: 'Login Admin/Juri',
            subtitle: 'Masuk sebagai admin atau juri',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.login);
            },
          ),

          _sectionTitle('Syarat Pendaftaran', Icons.fact_check_outlined),

          _infoCard(
            icon: Icons.badge_outlined,
            title: 'Mahasiswa Aktif',
            body:
            'Calon merupakan mahasiswa aktif dan memiliki identitas akademik yang valid.',
          ),
          _infoCard(
            icon: Icons.description_outlined,
            title: 'Berkas Lengkap',
            body:
            'Calon wajib mengisi data diri, visi, misi, mengunggah foto, dan mengunggah CV.',
          ),
          _infoCard(
            icon: Icons.email_outlined,
            title: 'Email Akademik',
            body:
            'Gunakan email akdemik karena hasil validasi diterima atau ditolak akan dikirim melalui email.',
          ),

          _sectionTitle('Alur Seleksi', Icons.route_outlined),

          _stepItem(
            '1',
            'Pendaftaran Online',
            'Calon mengisi formulir pendaftaran dan mengunggah berkas melalui aplikasi.',
          ),
          _stepItem(
            '2',
            'Validasi Admin',
            'Admin memeriksa data calon, foto, dan CV untuk menentukan valid atau ditolak.',
          ),
          _stepItem(
            '3',
            'Wawancara dan Penilaian',
            'Calon valid akan mengikuti proses wawancara dan dinilai oleh juri.',
          ),
          _stepItem(
            '4',
            'Perhitungan ARAS',
            'Nilai calon dihitung menggunakan metode ARAS untuk menentukan ranking akhir.',
          ),
          _stepItem(
            '5',
            'Pengumuman Hasil',
            'Hasil ranking akan tampil setelah admin mempublikasikan pengumuman.',
          ),

          _sectionTitle('FAQ', Icons.help_outline),

          _faqItem(
            'Apakah calon perlu membuat akun?',
            'Tidak. Calon cukup mengisi formulir pendaftaran publik tanpa login.',
          ),
          _faqItem(
            'Bagaimana mengetahui diterima atau ditolak?',
            'Sistem akan mengirim email ketika admin menerima atau menolak pendaftaran calon.',
          ),
          _faqItem(
            'Apa yang harus disiapkan sebelum daftar?',
            'Siapkan data diri, NIM, email aktif, foto, CV, visi, dan misi.',
          ),
          _faqItem(
            'Kapan hasil pemilihan bisa dilihat?',
            'Hasil dapat dilihat setelah admin menghitung dan mempublikasikan hasil ranking.',
          ),

          _sectionTitle('Kontak', Icons.contact_support_outlined),

          const Card(
            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Color(0xFF1E3A8A),
              ),
              title: Text('Informasi Seleksi Duta Kampus'),
              subtitle: Text(
                'Jika ada kendala pendaftaran, hubungi panitia pemilihan Duta Kampus melalui kontak resmi Humas PNJ.',
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Center(
            child: Text(
              '© 2026 Pemilihan Duta Kampus',
              style: TextStyle(color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}