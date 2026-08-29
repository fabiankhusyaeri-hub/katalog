import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> orders = [
      {'id': 'INV-001', 'date': '2026-08-01', 'status': 'Completed'},
      {'id': 'INV-002', 'date': '2026-08-10', 'status': 'Pending'},
      {'id': 'INV-003', 'date': '2026-08-15', 'status': 'Cancelled'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final o = orders[index];
          Color badgeColor;
          if (o['status'] == 'Completed') {
            badgeColor = Colors.green;
          } else if (o['status'] == 'Pending') {
            badgeColor = Colors.orange;
          } else {
            badgeColor = Colors.red;
          }

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(o['id'] ?? ''),
              subtitle: Text(o['date'] ?? ''),
              trailing: Chip(
                label: Text(o['status'] ?? ''),
                backgroundColor: badgeColor.withValues(alpha: 0.12),
              ),
              onTap: () {},
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: orders.length,
      ),
    );
  }
}
