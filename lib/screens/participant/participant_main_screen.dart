import 'package:flutter/material.dart';

import '../../app/colors.dart';
import 'participant_dashboard_screen.dart';
import 'participant_registration_screen.dart';
import 'participant_schedule_screen.dart';
import 'participant_result_screen.dart';

class ParticipantMainScreen extends StatefulWidget {
  const ParticipantMainScreen({super.key});

  @override
  State<ParticipantMainScreen> createState() => _ParticipantMainScreenState();
}

class _ParticipantMainScreenState extends State<ParticipantMainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    ParticipantDashboardScreen(),
    ParticipantRegistrationScreen(),
    ParticipantScheduleScreen(),
    ParticipantResultScreen(),
  ];

  final List<String> titles = const [
    'Dashboard Peserta',
    'Formulir Pendaftaran',
    'Jadwal Wawancara',
    'Hasil Seleksi',
  ];

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: changePage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Daftar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded),
            label: 'Hasil',
          ),
        ],
      ),
    );
  }
}