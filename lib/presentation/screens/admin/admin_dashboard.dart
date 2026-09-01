// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../app_shell.dart';
import 'admin_information.dart';
import 'admin_products.dart';
import 'admin_users.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .get();
    final ordersSnap = await FirebaseFirestore.instance
        .collection('orders')
        .get();

    final users = usersSnap.docs;
    int adminCount = 0;
    int siswaCount = 0;
    for (final doc in users) {
      final role = ((doc.data()['role'] ?? 'siswa') as String).toLowerCase();
      if (role == 'admin' || role == 'administrator') {
        adminCount++;
      } else {
        siswaCount++;
      }
    }

    final pendingOrders = ordersSnap.docs.where((d) {
      final status = (d.data()['status'] ?? '').toString().toLowerCase();
      return status == 'pending';
    }).length;

    final recentUsers = users.map((doc) {
      final data = doc.data();
      final role = (data['role'] ?? 'siswa').toString();
      return {
        'name': (data['name'] ?? data['email'] ?? 'User').toString(),
        'role': role,
        'email': (data['email'] ?? '').toString(),
      };
    }).toList();

    return {
      'totalUsers': users.length,
      'adminCount': adminCount,
      'siswaCount': siswaCount,
      'pendingOrders': pendingOrders,
      'recentUsers': recentUsers,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              final rootContext = context;
              final navigator = Navigator.of(rootContext);
              final confirm = await showDialog<bool>(
                context: rootContext,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Keluar akun?'),
                  content: const Text(
                    'Apakah Anda yakin ingin logout dari admin?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
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
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadDashboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data ??
              {
                'totalUsers': 0,
                'adminCount': 0,
                'siswaCount': 0,
                'pendingOrders': 0,
                'recentUsers': <Map<String, String>>[],
              };

          final stats = [
            {
              'label': 'Total User',
              'value': '${data['totalUsers']}',
              'color': Colors.blue,
            },
            {
              'label': 'Siswa',
              'value': '${data['siswaCount']}',
              'color': Colors.green,
            },
            {
              'label': 'Pending',
              'value': '${data['pendingOrders']}',
              'color': Colors.orange,
            },
            {
              'label': 'Admin',
              'value': '${data['adminCount']}',
              'color': Colors.red,
            },
          ];

          final recentUsers = (data['recentUsers'] as List?) ?? const [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  final color = stat['color'] as Color;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            stat['value'] as String,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat['label'] as String,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: (data['totalUsers'] as int).toDouble(),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: (data['siswaCount'] as int).toDouble(),
                                color: Colors.green,
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: (data['pendingOrders'] as int).toDouble(),
                                color: Colors.orange,
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY: (data['adminCount'] as int).toDouble(),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 24) / 3;
                  return SizedBox(
                    height: 150,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _AdminQuickActionCard(
                            icon: Icons.people_alt_rounded,
                            title: 'Kelola User',
                            subtitle: 'Manajemen akun',
                            color: Colors.blue,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AdminUsersScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _AdminQuickActionCard(
                            icon: Icons.inventory_2_outlined,
                            title: 'Produk',
                            subtitle: 'Stok & harga',
                            color: Colors.green,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AdminProductsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _AdminQuickActionCard(
                            icon: Icons.info_outline_rounded,
                            title: 'Kelola Informasi',
                            subtitle: 'Form murid',
                            color: Colors.purple,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminInformationScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: recentUsers.length > 6 ? 6 : recentUsers.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final user = recentUsers[index] as Map<String, dynamic>;
                    final name = user['name'] as String;
                    final role = user['role'] as String;
                    final avatarText = name.isNotEmpty
                        ? name.substring(0, 1).toUpperCase()
                        : '?';
                    return ListTile(
                      leading: CircleAvatar(child: Text(avatarText)),
                      title: Text(name),
                      subtitle: Text(user['email'] as String? ?? ''),
                      trailing: Chip(
                        label: Text(role),
                        backgroundColor: role.toLowerCase().contains('admin')
                            ? Colors.red.shade100
                            : Colors.blue.shade100,
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
}

class _AdminQuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminQuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
