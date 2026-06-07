import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await Future.delayed(const Duration(seconds: 1));
    await authProvider.checkLoginStatus();

    if (!mounted) return;

    if (!authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
      return;
    }

    if (authProvider.role == 'admin') {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } else if (authProvider.role == 'juri') {
      Navigator.pushReplacementNamed(context, AppRoutes.juryDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}