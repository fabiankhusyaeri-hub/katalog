import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = List.generate(
      10,
      (i) => {'name': 'Admin ${i + 1}', 'email': 'admin${i + 1}@example.com'},
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Admin')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (c, i) {
          final u = users[i];
          return ListTile(
            leading: CircleAvatar(child: Text(u['name']!.split(' ').last)),
            title: Text(u['name']!),
            subtitle: Text(u['email']!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.lock_reset),
                  onPressed: () {},
                ),
                IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
              ],
            ),
          );
        },
      ),
    );
  }
}
