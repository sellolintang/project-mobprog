import 'package:flutter/material.dart';

import '../../app/colors.dart';
import 'admin_dashboard_screen.dart';
import 'admin_participant_screen.dart';
import 'admin_criteria_screen.dart';
import 'admin_schedule_screen.dart';
import 'admin_result_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    AdminDashboardScreen(),
    AdminParticipantScreen(),
    AdminCriteriaScreen(),
    AdminScheduleScreen(),
    AdminResultScreen(),
  ];

  final List<String> titles = const [
    'Dashboard Admin',
    'Data Peserta',
    'Kriteria Seleksi',
    'Jadwal Wawancara',
    'Hasil ARAS',
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
            icon: Icon(Icons.groups_rounded),
            label: 'Peserta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rule_rounded),
            label: 'Kriteria',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'Hasil',
          ),
        ],
      ),
    );
  }
}