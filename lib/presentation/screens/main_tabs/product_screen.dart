import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String _selectedCategory = 'Semua';

  Widget _buildProductImage(String? imageUrl, {double? width, double? height}) {
    final resolvedUrl = (imageUrl ?? '').trim();
    final imageWidget =
        resolvedUrl.isNotEmpty &&
            (resolvedUrl.startsWith('http://') ||
                resolvedUrl.startsWith('https://'))
        ? Image.network(
            resolvedUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'lib/images/logoicon-removebg-preview.png',
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            'lib/images/logoicon-removebg-preview.png',
            width: width,
            height: height,
            fit: BoxFit.cover,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageWidget,
    );
  }

  String _productStatusLabel(String? rawStatus) {
    return (rawStatus ?? '').toLowerCase() == 'published'
        ? 'Published'
        : 'Draft';
  }

  Color _productStatusColor(String? rawStatus) {
    return (rawStatus ?? '').toLowerCase() == 'published'
        ? Colors.green
        : Colors.orange;
  }

  List<Map<String, dynamic>> _mapProducts(QuerySnapshot<Object?> snapshot) {
    final products = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final stock = (data['stock'] is num)
          ? (data['stock'] as num).toInt()
          : int.tryParse(data['stock']?.toString() ?? '') ?? 0;
      final price = (data['price'] is num)
          ? (data['price'] as num).toInt()
          : int.tryParse(data['price']?.toString() ?? '') ?? 0;

      return {
        'id': doc.id.hashCode.abs(),
        'firestoreId': doc.id,
        'title': (data['name'] ?? 'Produk').toString(),
        'category': (data['category'] ?? 'Umum').toString(),
        'description': (data['description'] ?? '').toString(),
        'imageUrl': (data['imageUrl'] ?? data['image'] ?? '').toString(),
        'price': price,
        'stock': stock,
        'status': (data['status'] ?? 'published').toString(),
      };
    }).toList();

    products.sort(
      (a, b) => (a['title'] as String).compareTo(b['title'] as String),
    );
    return products;
  }

  void _openProductDetail(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: MediaQuery.of(c).viewInsets,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: _buildProductImage(
                    product['imageUrl']?.toString(),
                    width: double.infinity,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product['title'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _productStatusColor(
                      product['status']?.toString(),
                    ).withAlpha(30),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _productStatusLabel(product['status']?.toString()),
                    style: TextStyle(
                      color: _productStatusColor(product['status']?.toString()),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                if ((product['description'] as String).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(product['description'] as String),
                ],
                const SizedBox(height: 8),
                Text('Kategori: ${product['category']}'),
                const SizedBox(height: 8),
                Text('Harga: Rp${product['price']}'),
                const SizedBox(height: 8),
                Text(
                  'Stok: ${product['stock']}',
                  style: TextStyle(
                    color: product['stock'] == 0 ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: product['stock'] == 0
                            ? null
                            : () {
                                Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                ).addItem(
                                  product['id'] as int,
                                  product['title'] as String,
                                  product['price'] as int,
                                );
                                Navigator.of(context).pop();
                              },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Cart'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: product['stock'] == 0
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CartScreen(),
                                  ),
                                );
                              },
                        child: const Text('Checkout Now (QRIS)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk & Belanja'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen())),
                ),
                if (cart.totalCount > 0)
                  Positioned(
                    right: 6,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      child: Text(
                        '${cart.totalCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) => FloatingActionButton.extended(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CartScreen())),
          icon: const Icon(Icons.shopping_cart),
          label: Text('Keranjang (${cart.totalCount})'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProducts = snapshot.data == null
              ? <Map<String, dynamic>>[]
              : _mapProducts(snapshot.data!);

          final categories = <String>{
            'Semua',
            ...allProducts.map((p) => p['category'] as String),
          }.toList();

          if (!categories.contains(_selectedCategory)) {
            _selectedCategory = 'Semua';
          }

          final filteredProducts = _selectedCategory == 'Semua'
              ? allProducts
              : allProducts
                    .where((p) => p['category'] == _selectedCategory)
                    .toList();

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(
                          child: Text('Belum ada produk yang tersedia'),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.78,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final p = filteredProducts[index];
                            return GestureDetector(
                              onTap: () => _openProductDetail(p),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildProductImage(
                                          p['imageUrl']?.toString(),
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        p['title'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _productStatusColor(
                                            p['status']?.toString(),
                                          ).withAlpha(30),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          _productStatusLabel(
                                            p['status']?.toString(),
                                          ),
                                          style: TextStyle(
                                            color: _productStatusColor(
                                              p['status']?.toString(),
                                            ),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp${p['price']}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: p['stock'] == 0
                                                ? Colors.red.shade100
                                                : Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            p['stock'] == 0
                                                ? 'Habis'
                                                : 'Stok ${p['stock']}',
                                            style: TextStyle(
                                              color: p['stock'] == 0
                                                  ? Colors.red
                                                  : Colors.green.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
