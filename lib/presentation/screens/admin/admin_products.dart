import 'package:flutter/material.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = List.generate(
      12,
      (i) => {'name': 'Product ${i + 1}', 'stock': '${(i + 1) * 3}'},
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        itemBuilder: (c, i) {
          final p = products[i];
          return Card(
            child: ListTile(
              title: Text(p['name']!),
              subtitle: Text('Stock: ${p['stock']}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
