import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../../domain/entities/user.dart' as domain;
import 'register_screen.dart';
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
  String _role = 'siswa';
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  domain.Role _mapRole(String r) {
    switch (r) {
      case 'admin':
        return domain.Role.admin;
      case 'hubin':
        return domain.Role.superAdmin;
      default:
        return domain.Role.siswa;
    }
  }

  Future<void> _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final goCallback = widget.go;
    setState(() => _loading = true);
    try {
      await auth.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: _mapRole(_role),
      );
      if (!mounted) return;
      goCallback(_role);
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
    final goCallback = widget.go;
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.signInWithGoogle();
      final role = auth.user?.role;
      if (!mounted) return;
      goCallback(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Masuk',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ToggleButtons(
                isSelected: [
                  _role == 'siswa',
                  _role == 'admin',
                  _role == 'hubin',
                ],
                onPressed: (i) => setState(
                  () => _role = i == 0
                      ? 'siswa'
                      : i == 1
                      ? 'admin'
                      : 'hubin',
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Siswa'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Admin'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Hubin'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email / NIS'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _loading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Masuk'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterScreen(goBack: (r) => widget.go(r)),
                            ),
                          ),
                          child: const Text('Daftar'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ResetPasswordScreen(),
                            ),
                          ),
                          child: const Text('Lupa password?'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _googleSignIn,
                          icon: const Icon(Icons.login),
                          label: const Text('Masuk dengan Google'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
