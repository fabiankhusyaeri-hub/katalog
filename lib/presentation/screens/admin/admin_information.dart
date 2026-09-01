import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminInformationScreen extends StatefulWidget {
  const AdminInformationScreen({super.key});

  @override
  State<AdminInformationScreen> createState() => _AdminInformationScreenState();
}

class _AdminInformationScreenState extends State<AdminInformationScreen> {
  Future<List<Map<String, dynamic>>> _loadInformation() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('student_form_info')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': (data['title'] ?? 'Informasi').toString(),
        'content': (data['content'] ?? '').toString(),
        'createdAt': data['createdAt'],
      };
    }).toList();
  }

  Future<void> _saveInformation({Map<String, dynamic>? item}) async {
    final isEdit = item != null;
    final titleController = TextEditingController(
      text: item?['title']?.toString() ?? '',
    );
    final contentController = TextEditingController(
      text: item?['content']?.toString() ?? '',
    );

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Informasi' : 'Tambah Informasi'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul informasi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Isi informasi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul dan isi informasi wajib diisi'),
                    ),
                  );
                  return;
                }

                Navigator.of(ctx).pop({'title': title, 'content': content});
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    final payload = {
      'title': result['title'] ?? '',
      'content': result['content'] ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isEdit) {
      await FirebaseFirestore.instance
          .collection('student_form_info')
          .doc(item['id'] as String)
          .update(payload);
    } else {
      await FirebaseFirestore.instance.collection('student_form_info').add({
        ...payload,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Informasi berhasil diperbarui'
                : 'Informasi berhasil ditambahkan',
          ),
        ),
      );
    }
  }

  Future<void> _deleteInformation(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus informasi?'),
        content: const Text('Item ini akan dihapus dari form murid.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('student_form_info')
        .doc(id)
        .delete();

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informasi berhasil dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Informasi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveInformation(),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Tambah Informasi'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadInformation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final infoList = snapshot.data ?? const [];
          if (infoList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada informasi untuk form murid.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: infoList.length,
            itemBuilder: (context, index) {
              final item = infoList[index];
              final title = (item['title'] ?? 'Informasi').toString();
              final content = (item['content'] ?? '').toString();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit informasi',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _saveInformation(item: item),
                          ),
                          IconButton(
                            tooltip: 'Hapus informasi',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _deleteInformation(item['id'] as String),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(content, style: const TextStyle(height: 1.5)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
