// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/user.dart' as domain;
import '../../providers/auth_provider.dart';
import '../app_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  Future<Map<String, dynamic>> _loadStudentProfile() async {
    final uid = context.read<AuthProvider>().user?.id;
    if (uid == null) {
      return {
        'name': 'Nama Siswa',
        'email': '',
        'nis': '',
        'kelas': '',
        'jurusan': '',
        'alamat': '',
      };
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data() ?? const {};
    final authName = context.read<AuthProvider>().user?.name ?? 'Nama Siswa';

    return {
      'name': (data['name'] ?? authName).toString(),
      'email': (data['email'] ?? context.read<AuthProvider>().user?.email ?? '')
          .toString(),
      'nis': (data['nis'] ?? data['nisn'] ?? '').toString(),
      'kelas': (data['kelas'] ?? '').toString(),
      'jurusan': (data['jurusan'] ?? '').toString(),
      'alamat': (data['alamat'] ?? '').toString(),
    };
  }

  Future<void> _showEditProfileDialog() async {
    final auth = context.read<AuthProvider>();
    final profile = await _loadStudentProfile();
    final nameController = TextEditingController(
      text: profile['name'] as String? ?? '',
    );
    final nisController = TextEditingController(
      text: profile['nis'] as String? ?? '',
    );
    final kelasController = TextEditingController(
      text: profile['kelas'] as String? ?? '',
    );
    final jurusanController = TextEditingController(
      text: profile['jurusan'] as String? ?? '',
    );
    final alamatController = TextEditingController(
      text: profile['alamat'] as String? ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil Siswa'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nisController,
                  decoration: const InputDecoration(
                    labelText: 'NIS',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: kelasController,
                  decoration: const InputDecoration(
                    labelText: 'Kelas',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: jurusanController,
                  decoration: const InputDecoration(
                    labelText: 'Jurusan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: alamatController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final newName = nameController.text.trim();
    final newNis = nisController.text.trim();
    final newKelas = kelasController.text.trim();
    final newJurusan = jurusanController.text.trim();
    final newAlamat = alamatController.text.trim();

    if (newName.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    try {
      final uid = auth.user?.id;
      final payload = {
        'name': newName,
        'nis': newNis,
        'kelas': newKelas,
        'jurusan': newJurusan,
        'alamat': newAlamat,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(payload, SetOptions(merge: true));
      }

      await fb.FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
      final provider = context.read<AuthProvider>();
      if (provider.user != null) {
        provider.user = domain.User(
          id: provider.user!.id,
          email: provider.user!.email,
          name: newName,
          role: provider.user!.role,
        );
      }

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil siswa berhasil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui profil: $e')));
    }
  }

  Future<void> _showSettingsDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Pengaturan Aplikasi'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    setStateDialog(() {
                      _notificationsEnabled = value;
                    });
                  },
                  title: const Text('Notifikasi'),
                  subtitle: const Text('Aktifkan pemberitahuan penting'),
                ),
                SwitchListTile(
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    setStateDialog(() {
                      _darkMode = value;
                    });
                  },
                  title: const Text('Tema gelap'),
                  subtitle: const Text('Gunakan tampilan gelap'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan berhasil disimpan')),
      );
    }
  }

  Future<void> _showContactDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hubungi Hubin / Admin'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: hubin@sekolah.example'),
            SizedBox(height: 8),
            Text('Telepon: +62 812-3456-7890'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final uri = Uri.parse('mailto:hubin@sekolah.example');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              if (context.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Email'),
          ),
          TextButton(
            onPressed: () async {
              final uri = Uri.parse('tel:+6281234567890');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              if (context.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Telepon'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadStudentProfile(),
      builder: (context, snapshot) {
        final profile =
            snapshot.data ??
            {
              'name': auth.user?.name ?? 'Nama Siswa',
              'email': auth.user?.email ?? '',
              'nis': '',
              'kelas': '',
              'jurusan': '',
              'alamat': '',
            };

        final name = (profile['name'] ?? auth.user?.name ?? 'Nama Siswa')
            .toString();
        final email = (profile['email'] ?? auth.user?.email ?? '').toString();
        final nis = (profile['nis'] ?? '').toString();
        final kelas = (profile['kelas'] ?? '').toString();
        final jurusan = (profile['jurusan'] ?? '').toString();
        final alamat = (profile['alamat'] ?? '').toString();

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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.person, size: 34),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email.isNotEmpty ? email : 'Belum ada email',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _showEditProfileDialog,
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit profil',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.badge_outlined),
                            const SizedBox(width: 8),
                            const Text(
                              'Data Siswa',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _showEditProfileDialog,
                              icon: const Icon(Icons.edit_note_outlined),
                              label: const Text('Edit'),
                            ),
                          ],
                        ),
                        const Divider(),
                        _profileRow('NIS', nis.isEmpty ? '-' : nis),
                        _profileRow('Kelas', kelas.isEmpty ? '-' : kelas),
                        _profileRow('Jurusan', jurusan.isEmpty ? '-' : jurusan),
                        _profileRow('Alamat', alamat.isEmpty ? '-' : alamat),
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
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Ya, Logout'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm != true) return;

                            await rootContext.read<AuthProvider>().logout();
                            if (!rootContext.mounted) return;
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const AppShell(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Pengaturan Aplikasi'),
                        subtitle: const Text('Notifikasi dan tampilan'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showSettingsDialog,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.contact_support_outlined),
                        title: const Text('Hubin / Admin'),
                        subtitle: const Text('hubin@sekolah.example'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showContactDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
