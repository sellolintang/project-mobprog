import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/role_selection_screen.dart';

import '../screens/admin/admin_main_screen.dart';
import '../screens/jury/jury_main_screen.dart';
import '../screens/participant/participant_main_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String landing = '/landing';
  static const String roleSelection = '/role-selection';

  static const String admin = '/admin';
  static const String jury = '/jury';
  static const String participant = '/participant';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    landing: (context) => const LandingScreen(),
    roleSelection: (context) => const RoleSelectionScreen(),

    admin: (context) => const AdminMainScreen(),
    jury: (context) => const JuryMainScreen(),
    participant: (context) => const ParticipantMainScreen(),
  };
}