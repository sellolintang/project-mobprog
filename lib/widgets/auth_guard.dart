import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../providers/auth_provider.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final List<String> allowedRoles;

  const AuthGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  late Future<void> _checkLoginFuture;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    _checkLoginFuture = context.read<AuthProvider>().checkLoginStatus();
  }

  void _redirectToLogin() {
    if (_hasRedirected || !mounted) return;

    _hasRedirected = true;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );

      navigator.pushNamedAndRemoveUntil(
        AppRoutes.login,
            (route) => false,
      );
    });
  }

  void _redirectToPublicHome() {
    if (_hasRedirected || !mounted) return;

    _hasRedirected = true;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Anda tidak memiliki akses ke halaman ini.'),
          backgroundColor: Colors.red,
        ),
      );

      navigator.pushNamedAndRemoveUntil(
        AppRoutes.publicHome,
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _checkLoginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final authProvider = context.watch<AuthProvider>();

        if (!authProvider.isLoggedIn) {
          _redirectToLogin();

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentRole = authProvider.role;

        if (currentRole == null || !widget.allowedRoles.contains(currentRole)) {
          _redirectToPublicHome();

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.child;
      },
    );
  }
}