import 'package:flutter/material.dart';

import 'admin_storage_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020817),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF334155), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kelola User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFF111827),
                      ),
                      columnSpacing: 28,
                      columns: const [
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: const [
                        DataRow(
                          cells: [
                            DataCell(Text('Admin A')),
                            DataCell(Text('admin@school.id')),
                            DataCell(Text('Admin')),
                            DataCell(Text('Aktif')),
                          ],
                        ),
                        DataRow(
                          cells: [
                            DataCell(Text('Guru B')),
                            DataCell(Text('guru@school.id')),
                            DataCell(Text('Guru')),
                            DataCell(Text('Aktif')),
                          ],
                        ),
                        DataRow(
                          cells: [
                            DataCell(Text('Siswa C')),
                            DataCell(Text('siswa@school.id')),
                            DataCell(Text('Siswa')),
                            DataCell(Text('Pending')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const AdminStoragePage(),
          ],
        ),
      ),
    );
  }
}
