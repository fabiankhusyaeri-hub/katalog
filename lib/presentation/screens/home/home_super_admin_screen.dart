import 'package:flutter/material.dart';

import '../admin/admin_users.dart';
import '../generic_screen.dart';
import '../super_admin/super_admin_reports_screen.dart';

class HomeSuperAdminScreen extends StatelessWidget {
  const HomeSuperAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Admin Aktif', 'value': '12', 'color': Colors.blue},
      {'label': 'Laporan', 'value': '48', 'color': Colors.green},
      {'label': 'Pending', 'value': '6', 'color': Colors.orange},
      {'label': 'Akses', 'value': '99%', 'color': Colors.purple},
    ];

    final actions = [
      {
        'title': 'Kelola Admin',
        'subtitle': 'Atur akun & akses admin',
        'icon': Icons.people_alt_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'Laporan',
        'subtitle': 'Riwayat & progres sekolah',
        'icon': Icons.assessment_rounded,
        'color': Colors.green,
      },
      {
        'title': 'Audit Akses',
        'subtitle': 'Pantau aktivitas akun',
        'icon': Icons.security_rounded,
        'color': Colors.orange,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Super Admin'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Selamat datang, Super Admin',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
          const Text(
            'Menu Inti',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...actions.map((action) {
            final color = action['color'] as Color;
            final title = action['title'] as String;
            final subtitle = action['subtitle'] as String;
            final icon = action['icon'] as IconData;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(title),
                  subtitle: Text(subtitle),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    if (title == 'Kelola Admin') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminUsersScreen(),
                        ),
                      );
                      return;
                    }

                    if (title == 'Laporan') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SuperAdminReportsScreen(),
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            GenericScreen(title: 'Audit Akses', onLogin: () {}),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
