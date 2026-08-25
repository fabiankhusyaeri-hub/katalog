import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [BarChartRodData(toY: 5)],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [BarChartRodData(toY: 3)],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [BarChartRodData(toY: 7)],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _RecentUsersList()),
          ],
        ),
      ),
    );
  }
}

class _RecentUsersList extends StatelessWidget {
  final List<Map<String, String>> items = List.generate(
    6,
    (i) => {'name': 'User #${i + 1}', 'role': i % 2 == 0 ? 'admin' : 'siswa'},
  );

  _RecentUsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemBuilder: (c, i) {
          final u = items[i];
          final name = u['name']!;
          final avatarText = name.isNotEmpty
              ? name.substring(name.length - 1)
              : '?';
          return ListTile(
            leading: CircleAvatar(child: Text(avatarText)),
            title: Text(name),
            subtitle: Text(u['role']!),
            trailing: TextButton(onPressed: () {}, child: const Text('Manage')),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: items.length,
      ),
    );
  }
}
