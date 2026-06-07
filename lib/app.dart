import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/period_provider.dart';

import 'screens/admin/periods/period_list_screen.dart';
import 'screens/admin/periods/period_form_screen.dart';

import 'providers/candidate_provider.dart';
import 'screens/admin/candidates/candidate_list_screen.dart';
import 'screens/admin/candidates/candidate_detail_screen.dart';

import 'providers/criterion_provider.dart';
import 'screens/admin/criteria/criterion_list_screen.dart';
import 'screens/admin/criteria/criterion_form_screen.dart';

import 'providers/jury_provider.dart';
import 'screens/admin/juries/jury_list_screen.dart';
import 'screens/admin/juries/jury_form_screen.dart';

import 'providers/interview_provider.dart';
import 'screens/admin/interviews/interview_list_screen.dart';
import 'screens/admin/interviews/interview_form_screen.dart';

import 'providers/aras_result_provider.dart';
import 'screens/admin/aras/aras_result_list_screen.dart';

import 'providers/score_provider.dart';
import 'screens/jury/scoring_candidate_screen.dart';
import 'screens/jury/scoring_form_screen.dart';
import 'screens/jury/scoring_history_screen.dart';

import 'screens/public/home_screen.dart';

import 'screens/public/candidate_registration_screen.dart';
import 'screens/public/registration_success_screen.dart';
import 'screens/public/public_result_screen.dart';

import 'screens/admin/monitoring/score_monitoring_screen.dart';

import 'core/routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/jury/jury_dashboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PeriodProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CandidateProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CriterionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => JuryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => InterviewProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ArasResultProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ScoreProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Duta Kampus Mobile',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        ),
        initialRoute: AppRoutes.publicHome,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.publicHome: (_) => const HomeScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
          AppRoutes.juryDashboard: (_) => const JuryDashboardScreen(),
          AppRoutes.periodList: (_) => const PeriodListScreen(),
          AppRoutes.periodForm: (_) => const PeriodFormScreen(),
          AppRoutes.candidateList: (_) => const CandidateListScreen(),
          AppRoutes.candidateDetail: (_) => const CandidateDetailScreen(),
          AppRoutes.criterionList: (_) => const CriterionListScreen(),
          AppRoutes.criterionForm: (_) => const CriterionFormScreen(),
          AppRoutes.juryList: (_) => const JuryListScreen(),
          AppRoutes.juryForm: (_) => const JuryFormScreen(),
          AppRoutes.interviewList: (_) => const InterviewListScreen(),
          AppRoutes.interviewForm: (_) => const InterviewFormScreen(),
          AppRoutes.arasResultList: (_) => const ArasResultListScreen(),
          AppRoutes.scoringCandidates: (_) => const ScoringCandidateScreen(),
          AppRoutes.scoringForm: (_) => const ScoringFormScreen(),
          AppRoutes.scoringHistory: (_) => const ScoringHistoryScreen(),
          AppRoutes.candidateRegistration: (_) => const CandidateRegistrationScreen(),
          AppRoutes.registrationSuccess: (_) => const RegistrationSuccessScreen(),
          AppRoutes.publicResult: (_) => const PublicResultScreen(),
          AppRoutes.scoreMonitoring: (_) => const ScoreMonitoringScreen(),
        },
      ),
    );
  }
}