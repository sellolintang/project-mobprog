import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.dart';

class DutaSelectApp extends StatelessWidget {
  const DutaSelectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Mobprog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}