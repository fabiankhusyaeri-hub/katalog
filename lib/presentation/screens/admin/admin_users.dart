import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _formatDate(Object? value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }
    if (value is DateTime) {
      return '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}';
    }
    return value?.toString() ?? '-';
  }

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final extraFields = Map<String, dynamic>.from(data)
        ..removeWhere(
          (key, value) => [
            'name',
            'email',
            'role',
            'phone',
            'address',
            'status',
            'createdAt',
            'updatedAt',
          ].contains(key),
        );

      return {
        'id': doc.id,
        'name': (data['name'] ?? data['email'] ?? 'User').toString(),
        'email': (data['email'] ?? '').toString(),
        'role': (data['role'] ?? 'siswa').toString(),
        'phone': (data['phone'] ?? data['no_hp'] ?? '').toString(),
        'address': (data['address'] ?? data['alamat'] ?? '').toString(),
        'status': (data['status'] ?? 'aktif').toString(),
        'createdAt': data['createdAt'],
        'extra': extraFields,
      };
    }).toList();
  }

  Future<void> _deleteUser(String id) async {
    await FirebaseFirestore.instance.collection('users').doc(id).delete();
    if (mounted) setState(() {});
  }

  Future<void> _updateRole(String id, String role) async {
    await FirebaseFirestore.instance.collection('users').doc(id).update({
      'role': role,
    });
    if (mounted) setState(() {});
  }

  void _showUserDetail(Map<String, dynamic> user) {
    final details = <MapEntry<String, String>>[
      MapEntry('ID User', (user['id'] ?? '-').toString()),
      MapEntry('Nama', (user['name'] ?? '-').toString()),
      MapEntry('Email', (user['email'] ?? '-').toString()),
      MapEntry('Role', (user['role'] ?? '-').toString()),
      MapEntry('Nomor HP', (user['phone'] ?? '-').toString()),
      MapEntry('Alamat', (user['address'] ?? '-').toString()),
      MapEntry('Status', (user['status'] ?? 'aktif').toString()),
      MapEntry('Tanggal Daftar', _formatDate(user['createdAt'])),
    ];

    final extraFields = (user['extra'] as Map<String, dynamic>? ?? const {});

    showDialog(
      context: context,
      builder: (ctx) {
        final name = (user['name'] ?? 'User').toString();
        final initials = name.isNotEmpty
            ? name.substring(0, 1).toUpperCase()
            : 'U';

        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(child: Text(initials)),
              const SizedBox(width: 12),
              Expanded(child: Text(name)),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...details.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              '${entry.key}:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(child: Text(entry.value)),
                        ],
                      ),
                    ),
                  ),
                  if (extraFields.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Detail Tambahan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: extraFields.entries.map((entry) {
                        final value = entry.value?.toString() ?? '-';
                        return Chip(label: Text('${entry.key}: $value'));
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAdmin() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'admin';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tambah Admin Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(
                          value: 'super_admin',
                          child: Text('Super Admin'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          selectedRole = value;
                          setStateDialog(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop({
                      'name': nameController.text.trim(),
                      'email': emailController.text.trim(),
                      'password': passwordController.text.trim(),
                      'role': selectedRole,
                    });
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final email = result['email'] ?? '';
    final password = result['password'] ?? '';
    final name = result['name'] ?? '';
    final role = result['role'] ?? 'admin';

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email dan password wajib diisi')),
        );
      }
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = credential.user?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name.isEmpty ? email.split('@').first : name,
        'email': email,
        'role': role,
        'status': 'aktif',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin baru berhasil ditambahkan')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Gagal menambah admin')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Admin')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAdmin,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Admin'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? <Map<String, dynamic>>[];
          if (users.isEmpty) {
            return const Center(child: Text('Belum ada user di Firestore'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final id = user['id'] ?? '';
              final name = user['name'] ?? 'User';
              final initials = name.substring(0, 1).toUpperCase();
              final role = user['role'] ?? 'siswa';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showUserDetail(user),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            initials,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user['email'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (id.isEmpty) return;
                            if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hapus user?'),
                                  content: const Text(
                                    'Akun ini akan dihapus dari Firestore.',
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
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) await _deleteUser(id);
                              return;
                            }
                            await _updateRole(id, value);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'admin',
                              child: Text('Jadikan Admin'),
                            ),
                            const PopupMenuItem(
                              value: 'siswa',
                              child: Text('Jadikan Siswa'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus User'),
                            ),
                          ],
                          child: Chip(
                            label: Text(
                              role,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            backgroundColor: role.toLowerCase() == 'admin'
                                ? Colors.red.shade600
                                : Colors.blue.shade600,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
