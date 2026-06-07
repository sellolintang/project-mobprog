import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.forgotPassword(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Instruksi reset password telah dikirim ke email Anda.'
              : authProvider.errorMessage ??
              'Gagal mengirim instruksi reset password.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
            (route) => false,
      );
    }
  }

  void _backToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  void _backToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.publicHome,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Password'),
        leading: IconButton(
          onPressed: _backToLogin,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali ke login',
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(
                              Icons.lock_reset_rounded,
                              size: 64,
                              color: Color(0xFF1E3A8A),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Reset Password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Masukkan email akun admin atau juri. Sistem akan mengirim instruksi reset password melalui email.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !authProvider.isLoading,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'contoh@email.com',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                final email = value?.trim() ?? '';

                                if (email.isEmpty) {
                                  return 'Email wajib diisi';
                                }

                                if (!email.contains('@') ||
                                    !email.contains('.')) {
                                  return 'Format email tidak valid';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed:
                              authProvider.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: authProvider.isLoading
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Icon(Icons.send_outlined),
                              label: Text(
                                authProvider.isLoading
                                    ? 'Mengirim...'
                                    : 'Kirim Instruksi Reset',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed:
                              authProvider.isLoading ? null : _backToLogin,
                              child: const Text('Kembali ke Login'),
                            ),
                            TextButton.icon(
                              onPressed:
                              authProvider.isLoading ? null : _backToHome,
                              icon: const Icon(Icons.home_outlined),
                              label: const Text('Kembali ke Halaman Utama'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}