// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../app_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      child: Icon(Icons.person, size: 36),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.user?.name ?? 'Nama Siswa',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(auth.user?.email ?? 'Kelas / Jurusan'),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: const Icon(Icons.logout, color: Colors.red),
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text('Keluar dari akun saat ini'),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.red,
                      ),
                      onTap: () async {
                        final rootContext = context;
                        final navigator = Navigator.of(rootContext);
                        final confirm = await showDialog<bool>(
                          context: rootContext,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Keluar akun?'),
                            content: const Text(
                              'Kamu akan keluar dari sesi login saat ini.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Batal'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Ya, Logout'),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        await rootContext.read<AuthProvider>().logout();
                        if (!rootContext.mounted) return;
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AppShell()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('App Settings'),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Hubin / Admin'),
                    subtitle: const Text('hubin@sekolah.example'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
