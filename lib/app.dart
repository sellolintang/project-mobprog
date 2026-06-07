import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';

import 'providers/auth_provider.dart';
import 'providers/period_provider.dart';
import 'providers/candidate_provider.dart';
import 'providers/criterion_provider.dart';
import 'providers/jury_provider.dart';
import 'providers/interview_provider.dart';
import 'providers/aras_result_provider.dart';
import 'providers/score_provider.dart';

import 'widgets/auth_guard.dart';
import 'screens/auth/security_settings_screen.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';

import 'screens/public/home_screen.dart';
import 'screens/public/candidate_registration_screen.dart';
import 'screens/public/registration_success_screen.dart';
import 'screens/public/public_result_screen.dart';

import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/periods/period_list_screen.dart';
import 'screens/admin/periods/period_form_screen.dart';
import 'screens/admin/candidates/candidate_list_screen.dart';
import 'screens/admin/candidates/candidate_detail_screen.dart';
import 'screens/admin/criteria/criterion_list_screen.dart';
import 'screens/admin/criteria/criterion_form_screen.dart';
import 'screens/admin/juries/jury_list_screen.dart';
import 'screens/admin/juries/jury_form_screen.dart';
import 'screens/admin/interviews/interview_list_screen.dart';
import 'screens/admin/interviews/interview_form_screen.dart';
import 'screens/admin/aras/aras_result_list_screen.dart';
import 'screens/admin/monitoring/score_monitoring_screen.dart';

import 'screens/jury/jury_dashboard_screen.dart';
import 'screens/jury/scoring_candidate_screen.dart';
import 'screens/jury/scoring_form_screen.dart';
import 'screens/jury/scoring_history_screen.dart';

import 'screens/auth/forgot_password_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const List<String> _adminOnly = ['admin'];
  static const List<String> _juryOnly = ['juri'];

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

        // Tetap publicHome agar calon bisa membuka aplikasi tanpa login.
        initialRoute: AppRoutes.publicHome,

        routes: {
          // Public routes
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.publicHome: (_) => const HomeScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
          AppRoutes.candidateRegistration: (_) =>
          const CandidateRegistrationScreen(),
          AppRoutes.registrationSuccess: (_) =>
          const RegistrationSuccessScreen(),
          AppRoutes.publicResult: (_) => const PublicResultScreen(),

          AppRoutes.securitySettings: (_) => const AuthGuard(
            allowedRoles: ['admin', 'juri'],
            child: SecuritySettingsScreen(),
          ),

          // Admin routes
          AppRoutes.adminDashboard: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: AdminDashboardScreen(),
          ),
          AppRoutes.periodList: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: PeriodListScreen(),
          ),
          AppRoutes.periodForm: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: PeriodFormScreen(),
          ),
          AppRoutes.candidateList: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: CandidateListScreen(),
          ),
          AppRoutes.candidateDetail: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: CandidateDetailScreen(),
          ),
          AppRoutes.criterionList: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: CriterionListScreen(),
          ),
          AppRoutes.criterionForm: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: CriterionFormScreen(),
          ),
          AppRoutes.juryList: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: JuryListScreen(),
          ),
          AppRoutes.juryForm: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: JuryFormScreen(),
          ),
          AppRoutes.interviewList: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: InterviewListScreen(),
          ),
          AppRoutes.interviewForm: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: InterviewFormScreen(),
          ),
          AppRoutes.arasResultList: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: ArasResultListScreen(),
          ),
          AppRoutes.scoreMonitoring: (_) => const AuthGuard(
            allowedRoles: _adminOnly,
            child: ScoreMonitoringScreen(),
          ),

          // Jury routes
          AppRoutes.juryDashboard: (_) => const AuthGuard(
            allowedRoles: _juryOnly,
            child: JuryDashboardScreen(),
          ),
          AppRoutes.scoringCandidates: (_) => const AuthGuard(
            allowedRoles: _juryOnly,
            child: ScoringCandidateScreen(),
          ),
          AppRoutes.scoringForm: (_) => const AuthGuard(
            allowedRoles: _juryOnly,
            child: ScoringFormScreen(),
          ),
          AppRoutes.scoringHistory: (_) => const AuthGuard(
            allowedRoles: _juryOnly,
            child: ScoringHistoryScreen(),
          ),
        },
      ),
    );
  }
}