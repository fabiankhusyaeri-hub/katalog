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
  final List<Map<String, dynamic>> _products = List.generate(
    12,
    (i) => {
      'id': i,
      'title': 'Produk ${i + 1}',
      'price': 5000 + i * 1000,
      'stock': i % 4 == 0 ? 0 : (5 + i),
    },
  );

  void _openProductDetail(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: MediaQuery.of(c).viewInsets,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  Chip(label: Text('Semua')),
                  SizedBox(width: 8),
                  Chip(label: Text('Alat Tulis')),
                  SizedBox(width: 8),
                  Chip(label: Text('Seragam')),
                  SizedBox(width: 8),
                  Chip(label: Text('Elektronik')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final p = _products[index];
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.image,
                                  size: 56,
                                  color: Colors.black26,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp${p['price']}',
                              style: const TextStyle(color: Colors.green),
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
                                  borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}
