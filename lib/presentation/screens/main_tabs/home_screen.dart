import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Stream<List<Map<String, dynamic>>> _loadInformation() {
    return FirebaseFirestore.instance
        .collection('student_form_info')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': (data['title'] ?? 'Informasi').toString(),
              'content': (data['content'] ?? '').toString(),
            };
          }).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _loadInformation(),
        builder: (context, snapshot) {
          final infoList = snapshot.data ?? const <Map<String, dynamic>>[];

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              SizedBox(
                height: 160,
                child: PageView(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('SMK TI GARUDA NUSANTARA CIMAHI'),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('RPL • TKJ • MP • TJA • Animasi • DKV'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Profil Sekolah',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('SMK TI GARUDA NUSANTARA CIMAHI'),
                      SizedBox(height: 6),
                      Text(
                        'Sekolah vokasi yang fokus pada teknologi informasi dan industri kreatif.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Informasi penting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (infoList.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Belum ada informasi dari admin.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                )
              else
                ...infoList.map((info) {
                  final title = (info['title'] ?? 'Informasi').toString();
                  final content = (info['content'] ?? '').toString();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(title),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          content,
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              const Text(
                'Berita & Kegiatan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Workshop Programming'),
                      SizedBox(height: 6),
                      Text('Tanggal: 2026-09-01'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
