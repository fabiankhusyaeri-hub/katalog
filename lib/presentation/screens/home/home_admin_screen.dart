import 'package:flutter/material.dart';

class HomeAdminScreen extends StatelessWidget {
  final void Function(String) go;
  const HomeAdminScreen({super.key, required this.go});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Halaman Admin'),
            ElevatedButton(
              onPressed: () => go('admin-products'),
              child: const Text('Produk'),
            ),
          ],
        ),
      ),
    );
  }
}
