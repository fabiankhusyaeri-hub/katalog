import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _selectedProductStatus = 'Semua';

  Future<List<Map<String, dynamic>>> _loadProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': (data['name'] ?? 'Produk').toString(),
        'category': (data['category'] ?? 'Umum').toString(),
        'description': (data['description'] ?? '').toString(),
        'imageUrl': (data['imageUrl'] ?? data['image'] ?? '').toString(),
        'barcode': (data['barcode'] ?? '').toString(),
        'stock': (data['stock'] ?? 0).toString(),
        'price': (data['price'] ?? 0).toString(),
        'status': (data['status'] ?? 'published').toString(),
        'sourceWarehouseId': (data['sourceWarehouseId'] ?? '').toString(),
      };
    }).toList();
  }

  Future<String?> _scanBarcode() async {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Scan Kode Barang')),
          body: MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final value = barcodes.first.rawValue;
              if (value != null && value.trim().isNotEmpty) {
                Navigator.of(context).pop(value.trim());
              }
            },
          ),
        ),
      ),
    );
  }

  Future<String?> _uploadProductImageToStorage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (pickedFile == null) return null;

    final file = File(pickedFile.path);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
    final storageRef = FirebaseStorage.instance.ref().child(
      'product_images/$fileName',
    );

    final uploadTask = await storageRef.putFile(file);
    if (uploadTask.state == TaskState.success) {
      return await storageRef.getDownloadURL();
    }

    return null;
  }

  Future<void> _toggleProductStatus(Map<String, dynamic> product) async {
    final productId = product['id'] as String;
    final currentStatus = (product['status'] ?? 'published')
        .toString()
        .toLowerCase();
    final nextStatus = currentStatus == 'published' ? 'draft' : 'published';
    final productName = (product['name'] ?? 'Produk').toString();

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'status': nextStatus});

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextStatus == 'published'
                ? 'Produk "$productName" dipublish.'
                : 'Produk "$productName" di-unpublish.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status produk: $e')),
      );
    }
  }

  Future<void> _showProductDialog({Map<String, dynamic>? product}) async {
    final isEdit = product != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: product?['name']?.toString() ?? '',
    );
    final categoryController = TextEditingController(
      text: product?['category']?.toString() ?? 'Umum',
    );
    final descriptionController = TextEditingController(
      text: product?['description']?.toString() ?? '',
    );
    final imageUrlController = TextEditingController(
      text: product?['imageUrl']?.toString() ?? '',
    );
    final barcodeController = TextEditingController(
      text: product?['barcode']?.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?['stock']?.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: product?['price']?.toString() ?? '',
    );

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
              content: SizedBox(
                width: 480,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Informasi Produk',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nama produk',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Nama produk wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: categoryController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: imageUrlController,
                                keyboardType: TextInputType.url,
                                decoration: const InputDecoration(
                                  labelText: 'URL Foto Produk',
                                  hintText: 'https://example.com/foto.jpg',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.image_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              tooltip: 'Upload foto produk ke Firebase Storage',
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.maybeOf(
                                  context,
                                );
                                final uploadedUrl =
                                    await _uploadProductImageToStorage();
                                if (!mounted) return;
                                if (uploadedUrl != null &&
                                    uploadedUrl.isNotEmpty) {
                                  imageUrlController.text = uploadedUrl;
                                  setStateDialog(() {});
                                  messenger?.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Foto produk berhasil diupload ke Firebase Storage',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.upload_file_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if ((imageUrlController.text).trim().isNotEmpty)
                          Container(
                            height: 140,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey.shade100,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              imageUrlController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: barcodeController,
                          decoration: InputDecoration(
                            labelText: 'Kode Barang',
                            hintText: 'Scan QR / barcode produk',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.qr_code_scanner_rounded,
                            ),
                            suffixIcon: IconButton(
                              tooltip: 'Scan kode barang',
                              onPressed: () async {
                                final scanned = await _scanBarcode();
                                if (scanned != null && scanned.isNotEmpty) {
                                  barcodeController.text = scanned;
                                }
                              },
                              icon: const Icon(Icons.camera_alt_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: stockController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Stok',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.format_list_numbered),
                                ),
                                validator: (value) {
                                  if (int.tryParse(value ?? '') == null) {
                                    return 'Stok harus angka';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Harga',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.payments_outlined),
                                ),
                                validator: (value) {
                                  if (int.tryParse(value ?? '') == null) {
                                    return 'Harga harus angka';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Batal'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.of(ctx).pop({
                        'name': nameController.text.trim(),
                        'category': categoryController.text.trim().isEmpty
                            ? 'Umum'
                            : categoryController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'imageUrl': imageUrlController.text.trim(),
                        'barcode': barcodeController.text.trim(),
                        'stock': stockController.text.trim(),
                        'price': priceController.text.trim(),
                      });
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final payload = {
      'name': result['name'] ?? '',
      'category': result['category'] ?? 'Umum',
      'description': result['description'] ?? '',
      'imageUrl': result['imageUrl'] ?? '',
      'barcode': result['barcode'] ?? '',
      'stock': int.tryParse(result['stock'] ?? '') ?? 0,
      'price': int.tryParse(result['price'] ?? '') ?? 0,
      'status': 'published',
    };

    if (payload['name'].toString().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama produk tidak boleh kosong')),
        );
      }
      return;
    }

    if (!isEdit) {
      await FirebaseFirestore.instance.collection('products').add(payload);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk baru berhasil ditambahkan')),
        );
      }
      return;
    }

    await FirebaseFirestore.instance
        .collection('products')
        .doc(product['id'] as String)
        .update(payload);

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Produk berhasil diperbarui'
                : 'Produk baru berhasil ditambahkan',
          ),
        ),
      );
    }
  }

  Future<void> _deleteProductWithWarehouseSync(
    Map<String, dynamic> product,
  ) async {
    final productName = (product['name'] ?? 'produk').toString();
    final sourceWarehouseId = (product['sourceWarehouseId'] ?? '').toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text(
          sourceWarehouseId.isNotEmpty
              ? 'Produk "$productName" akan dihapus dan data stok yang berasal dari gudang juga akan dihapus.'
              : 'Produk "$productName" akan dihapus dari Firestore.',
        ),
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

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product['id'] as String)
          .delete();

      if (sourceWarehouseId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('warehouse_storage')
            .doc(sourceWarehouseId)
            .delete();
      }

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk "$productName" berhasil dihapus.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus produk: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data ?? <Map<String, dynamic>>[];
          if (products.isEmpty) {
            return const Center(child: Text('Belum ada produk di Firestore'));
          }

          final visibleProducts = _selectedProductStatus == 'Semua'
              ? products
              : products.where((product) {
                  final status = (product['status'] ?? 'published')
                      .toString()
                      .toLowerCase();
                  return status == _selectedProductStatus.toLowerCase();
                }).toList();

          if (visibleProducts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Semua', 'Published', 'Draft'].map((status) {
                      final selected = _selectedProductStatus == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: selected,
                        onSelected: (_) => setState(() {
                          _selectedProductStatus = status;
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Tidak ada produk untuk status ini'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Semua', 'Published', 'Draft'].map((status) {
                    final selected = _selectedProductStatus == status;
                    return ChoiceChip(
                      label: Text(status),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        _selectedProductStatus = status;
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: visibleProducts.length,
                    itemBuilder: (context, index) {
                      final product = visibleProducts[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child:
                                    (product['imageUrl'] ?? '')
                                        .toString()
                                        .trim()
                                        .isEmpty
                                    ? Image.asset(
                                        'lib/images/logoicon-removebg-preview.png',
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        (product['imageUrl'] ?? '').toString(),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'lib/images/logoicon-removebg-preview.png',
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        if ((product['barcode'] ?? '')
                                            .toString()
                                            .trim()
                                            .isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'Kode: ${product['barcode']}',
                                              style: TextStyle(
                                                color: Colors.purple.shade700,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                ((product['status'] ??
                                                            'published')
                                                        .toString()
                                                        .toLowerCase() ==
                                                    'published')
                                                ? Colors.green.shade50
                                                : Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            ((product['status'] ?? 'published')
                                                        .toString()
                                                        .toLowerCase() ==
                                                    'published')
                                                ? 'Published'
                                                : 'Draft',
                                            style: TextStyle(
                                              color:
                                                  ((product['status'] ??
                                                              'published')
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'published')
                                                  ? Colors.green.shade700
                                                  : Colors.orange.shade800,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            'Stok ${product['stock']}',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            'Rp${product['price']}',
                                            style: TextStyle(
                                              color: Colors.orange.shade800,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () =>
                                              _toggleProductStatus(product),
                                          icon: Icon(
                                            ((product['status'] ?? 'published')
                                                        .toString()
                                                        .toLowerCase() ==
                                                    'published')
                                                ? Icons.visibility_off_outlined
                                                : Icons.public_rounded,
                                          ),
                                          label: Text(
                                            ((product['status'] ?? 'published')
                                                        .toString()
                                                        .toLowerCase() ==
                                                    'published')
                                                ? 'Unpublish'
                                                : 'Publish',
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Edit produk',
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () => _showProductDialog(
                                            product: product,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Hapus produk',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteProductWithWarehouseSync(
                                                product,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
