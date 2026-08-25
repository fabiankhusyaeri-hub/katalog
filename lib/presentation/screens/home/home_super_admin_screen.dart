import 'package:flutter/material.dart';

class HomeSuperAdminScreen extends StatelessWidget {
  const HomeSuperAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Super Admin')),
      body: const Center(child: Text('Halaman Super Admin')),
    );
  }
}
