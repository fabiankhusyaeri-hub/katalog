import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart' as app_auth;

class SuperAdminAccessAuditScreen extends StatefulWidget {
  const SuperAdminAccessAuditScreen({super.key});

  @override
  State<SuperAdminAccessAuditScreen> createState() =>
      _SuperAdminAccessAuditScreenState();
}

class _SuperAdminAccessAuditScreenState
    extends State<SuperAdminAccessAuditScreen> {
  String _selectedRole = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recordScreenAccess());
  }

  Future<void> _recordScreenAccess() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final auth = context.read<app_auth.AuthProvider>();
    final role = _normalizeRole(auth.user?.role.name ?? 'super_admin');

    try {
      await FirebaseFirestore.instance.collection('access_audit').add({
        'userId': currentUser.uid,
        'email': currentUser.email ?? '-',
        'role': role,
        'action': 'view_audit_access',
        'method': 'mobile_app',
        'createdAt': FieldValue.serverTimestamp(),
        'description': 'Super admin membuka halaman audit akses',
      });
    } catch (_) {
      // silent fail to avoid blocking the screen
    }
  }

  String _normalizeRole(String value) {
    final role = value.trim();
    if (role.toLowerCase() == 'superadmin' || role.toLowerCase() == 'hubin') {
      return 'super_admin';
    }
    if (role.toLowerCase() == 'super_admin') {
      return 'super_admin';
    }
    return role.toLowerCase();
  }

  Stream<List<Map<String, dynamic>>> _loadAudit() {
    return FirebaseFirestore.instance
        .collection('access_audit')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final timestamp = data['createdAt'];
            final role = _normalizeRole((data['role'] ?? 'unknown').toString());
            return {
              'id': doc.id,
              'userId': (data['userId'] ?? '').toString(),
              'email': (data['email'] ?? '-').toString(),
              'role': role,
              'action': (data['action'] ?? 'login').toString(),
              'method': (data['method'] ?? '-').toString(),
              'description': (data['description'] ?? '').toString(),
              'createdAt': timestamp,
            };
          }).toList();
        });
  }

  String _formatDate(Object? value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (value is DateTime) {
      final date = value;
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return 'Belum ada waktu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Akses')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _loadAudit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat audit akses: ${snapshot.error}'),
            );
          }

          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          final filtered = _selectedRole == 'Semua'
              ? items
              : items
                    .where(
                      (item) => item['role'] == _selectedRole.toLowerCase(),
                    )
                    .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Semua', 'super_admin', 'admin', 'siswa'].map((
                      role,
                    ) {
                      final selected = role == _selectedRole;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            role == 'Semua' ? 'Semua' : role,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : null,
                            ),
                          ),
                          selected: selected,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          onSelected: (_) =>
                              setState(() => _selectedRole = role),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Belum ada data audit akses.'),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final role = (item['role'] ?? 'unknown').toString();
                          final action = (item['action'] ?? '').toString();
                          final method = (item['method'] ?? '').toString();

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _roleColor(role),
                                child: Text(
                                  role.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                item['email'] ?? 'Unknown user',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Role: $role'),
                                  Text('Aksi: $action'),
                                  Text('Metode: $method'),
                                  Text(_formatDate(item['createdAt'])),
                                ],
                              ),
                              trailing: Icon(
                                action.contains('login')
                                    ? Icons.login_rounded
                                    : Icons.history_rounded,
                                color: _roleColor(role),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'hubin':
        return Colors.purple;
      case 'admin':
        return Colors.blue;
      case 'siswa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
