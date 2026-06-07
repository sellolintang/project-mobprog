import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isLoading = true;
  bool _deviceSupported = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    final authProvider = context.read<AuthProvider>();

    final deviceSupported = await authProvider.canDeviceUseBiometric();
    final biometricEnabled = await authProvider.isBiometricEnabled();

    if (!mounted) return;

    setState(() {
      _deviceSupported = deviceSupported;
      _biometricEnabled = biometricEnabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final authProvider = context.read<AuthProvider>();

    setState(() {
      _isLoading = true;
    });

    if (value) {
      final canUse = await authProvider.canDeviceUseBiometric();

      if (!mounted) return;

      if (!canUse) {
        setState(() {
          _deviceSupported = false;
          _biometricEnabled = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Perangkat ini belum mendukung biometric atau biometric belum diatur.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await authProvider.enableBiometricLogin();
    } else {
      await authProvider.disableBiometricLogin();
    }

    await _loadSecurityStatus();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Biometric login berhasil diaktifkan.'
              : 'Biometric login berhasil dinonaktifkan.',
        ),
        backgroundColor: value ? Colors.green : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keamanan Akun'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(user?.name ?? 'User'),
              subtitle: Text(user?.email ?? '-'),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text(
                'Biometric Login',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _deviceSupported
                    ? 'Gunakan fingerprint, face unlock, PIN, atau passcode perangkat untuk login.'
                    : 'Biometric belum tersedia di perangkat ini.',
              ),
              value: _biometricEnabled && _deviceSupported,
              onChanged: _deviceSupported ? _toggleBiometric : null,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: Icon(
                _deviceSupported
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                color: _deviceSupported ? Colors.green : Colors.orange,
              ),
              title: const Text('Status Perangkat'),
              subtitle: Text(
                _deviceSupported
                    ? 'Perangkat mendukung biometric login.'
                    : 'Perangkat tidak mendukung biometric, belum punya fingerprint/face unlock, atau sedang berjalan di platform yang tidak mendukung.',
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Catatan: biometric login hanya muncul jika user pernah login normal, token masih tersimpan, dan fitur biometric aktif. Jika user logout, token akan dihapus sehingga user perlu login normal kembali.',
                style: TextStyle(
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}