import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../../domain/entities/user.dart' as domain;
import 'reset_password_screen.dart';

typedef GoCallback = void Function(String role);

class LoginScreen extends StatefulWidget {
  final GoCallback go;
  final VoidCallback back;
  const LoginScreen({super.key, required this.go, required this.back});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _loading = true);
    try {
      await auth.login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
      if (!mounted) return;
      final r = auth.user?.role;
      widget.go(
        r == domain.Role.admin
            ? 'admin'
            : r == domain.Role.superAdmin
            ? 'hubin'
            : 'siswa',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.signInWithGoogle();
      final role = auth.user?.role;
      if (!mounted) return;
      widget.go(
        role == domain.Role.admin
            ? 'admin'
            : role == domain.Role.superAdmin
            ? 'hubin'
            : 'siswa',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in gagal: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Masuk ke Katalog Sekolah',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Email atau NIS',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Masukkan email atau NIS'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Password minimal 6 karakter'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        _loading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        _submit();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton(
                                    onPressed: _googleSignIn,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.login),
                                        SizedBox(width: 8),
                                        Text('Masuk dengan Google'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ResetPasswordScreen(),
                                      ),
                                    ),
                                    child: const Text('Lupa password?'),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
