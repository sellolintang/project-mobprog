import 'package:flutter/material.dart';

import '../../app/colors.dart';
import 'jury_dashboard_screen.dart';
import 'jury_evaluation_screen.dart';
import 'jury_result_screen.dart';

class JuryMainScreen extends StatefulWidget {
  const JuryMainScreen({super.key});

  @override
  State<JuryMainScreen> createState() => _JuryMainScreenState();
}

class _JuryMainScreenState extends State<JuryMainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    JuryDashboardScreen(),
    JuryEvaluationScreen(),
    JuryResultScreen(),
  ];

  final List<String> titles = const [
    'Dashboard Juri',
    'Penilaian Peserta',
    'Hasil Penilaian',
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
            icon: Icon(Icons.rate_review_rounded),
            label: 'Penilaian',
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