import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'services/wa_service.dart';

class AdminStoragePage extends StatefulWidget {
  const AdminStoragePage({super.key});

  @override
  State<AdminStoragePage> createState() => _AdminStoragePageState();
}

class _AdminStoragePageState extends State<AdminStoragePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _statusLabel(String? rawStatus) {
    final status = (rawStatus ?? '').toLowerCase();
    if (status == 'published') {
      return 'Published';
    }
    return 'Gudang';
  }

  Color _statusColor(String? rawStatus) {
    final status = (rawStatus ?? '').toLowerCase();
    if (status == 'published') {
      return const Color(0xFF34D399);
    }
    return const Color(0xFFFBBF24);
  }

  Future<void> _deleteWarehouseItem(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Hapus stok?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Yakin ingin menghapus stok "$name" dari gudang?',
          style: const TextStyle(color: Color(0xFFCBD5E1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _firestore.collection('warehouse_storage').doc(id).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Stok "$name" berhasil dihapus.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus stok: $e')));
    }
  }

  Future<void> _showAddStockDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final stockController = TextEditingController();
    final locationController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Tambah Stok Gudang',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nama Barang',
                      labelStyle: TextStyle(color: Color(0xFFCBD5E1)),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Nama barang wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Stok',
                      labelStyle: TextStyle(color: Color(0xFFCBD5E1)),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed < 0) {
                        return 'Jumlah stok harus angka dan tidak boleh negatif';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: locationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Lokasi Rak',
                      labelStyle: TextStyle(color: Color(0xFFCBD5E1)),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Lokasi rak wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      final name = nameController.text.trim();
      final stock = int.parse(stockController.text.trim());
      final location = locationController.text.trim();

      await _firestore.collection('warehouse_storage').add({
        'name': name,
        'stock': stock,
        'location': location,
        'status': 'warehouse',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final waResult = await WaService.sendNotification(
        'Stok Gudang Baru\nNama Barang: $name\nJumlah Pcs: $stock\nLokasi Rak: $location',
      );

      if (!waResult) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stok tersimpan, gagal kirim notifikasi WA'),
          ),
        );
      } else {
        debugPrint('WA notification sent for new warehouse stock');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok gudang berhasil ditambahkan.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambah stok gudang: $e')));
    }
  }

  Future<void> _showPublishDialog(Map<String, dynamic> item) async {
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Jadikan Produk',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Barang: ${item['name'] ?? '-'}',
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Harga Jual',
                      labelStyle: TextStyle(color: Color(0xFFCBD5E1)),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed < 0) {
                        return 'Harga jual harus angka dan tidak boleh negatif';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Produk',
                      labelStyle: TextStyle(color: Color(0xFFCBD5E1)),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Deskripsi produk wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              icon: const Icon(Icons.arrow_upward_rounded),
              label: const Text('Publikasikan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final warehouseId = item['id']?.toString() ?? '';
    final name = (item['name'] ?? '').toString();
    final stock = int.tryParse((item['stock'] ?? '0').toString()) ?? 0;
    final price = int.parse(priceController.text.trim());
    final description = descriptionController.text.trim();

    try {
      await _firestore.collection('products').add({
        'name': name,
        'price': price,
        'description': description,
        'stock': stock,
        'category': 'Umum',
        'imageUrl': '',
        'status': 'published',
        'createdAt': FieldValue.serverTimestamp(),
        'sourceWarehouseId': warehouseId,
      });

      if (warehouseId.isNotEmpty) {
        await _firestore
            .collection('warehouse_storage')
            .doc(warehouseId)
            .update({
              'status': 'published',
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }

      try {
        await WaService.sendNotification(
          'Produk Baru Dirilis\nNama Produk: $name\nHarga Jual: Rp$price\nStok Dirilis: $stock',
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Produk berhasil dirilis, gagal kirim notifikasi WA: $e',
            ),
          ),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barang "$name" berhasil dirilis menjadi produk.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal merilis produk: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Stok Gudang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _showAddStockDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah Stok'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari nama barang atau lokasi rak...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF94A3B8),
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('warehouse_storage')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Gagal memuat stok gudang: ${snapshot.error}',
                    style: const TextStyle(color: Color(0xFFF87171)),
                  ),
                );
              }

              final allDocs =
                  snapshot.data?.docs ??
                  <QueryDocumentSnapshot<Map<String, dynamic>>>[];

              final query = _searchController.text.trim().toLowerCase();
              final docs = query.isEmpty
                  ? allDocs
                  : allDocs.where((doc) {
                      final item = doc.data();
                      final name = (item['name'] ?? '')
                          .toString()
                          .toLowerCase();
                      final location = (item['location'] ?? '')
                          .toString()
                          .toLowerCase();
                      return name.contains(query) || location.contains(query);
                    }).toList();

              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF111827),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Center(
                    child: Text(
                      query.isEmpty
                          ? 'Belum ada data stok gudang.'
                          : 'Tidak ada stok gudang yang cocok dengan pencarian.',
                      style: const TextStyle(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFF111827),
                        ),
                        columnSpacing: 24,
                        horizontalMargin: 16,
                        dataRowMinHeight: 64,
                        dataRowMaxHeight: 72,
                        columns: const [
                          DataColumn(label: Text('Nama Barang')),
                          DataColumn(label: Text('Jumlah')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: docs.map((doc) {
                          final item = doc.data();
                          final name = (item['name'] ?? '-').toString();
                          final stock =
                              int.tryParse((item['stock'] ?? '0').toString()) ??
                              0;
                          final location = (item['location'] ?? '-').toString();
                          final status = (item['status'] ?? 'warehouse')
                              .toString();
                          final published = status.toLowerCase() == 'published';

                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      location,
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  '$stock',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(status).withAlpha(30),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    _statusLabel(status),
                                    style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!published)
                                      FilledButton.tonal(
                                        onPressed: () => _showPublishDialog({
                                          'id': doc.id,
                                          'name': name,
                                          'stock': stock,
                                          'status': status,
                                        }),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF22C55E,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Jadikan Produk'),
                                      )
                                    else
                                      const Text(
                                        'Sudah Rilis',
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: 'Hapus stok',
                                      onPressed: () =>
                                          _deleteWarehouseItem(doc.id, name),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
