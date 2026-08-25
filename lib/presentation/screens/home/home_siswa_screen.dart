import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class Product {
  final int id;
  final String name;
  final int price;
  final String category;
  final int stock;
  final String badge;

  Product(
    this.id,
    this.name,
    this.price,
    this.category,
    this.stock,
    this.badge,
  );
}

final List<Product> mockProducts = [
  Product(1, 'Arduino Uno R3', 85000, 'Elektronika', 12, 'Tersedia'),
  Product(2, 'Breadboard 830 Titik', 25000, 'Elektronika', 3, 'Stok Terbatas'),
  Product(3, 'Kabel UTP Cat6 (1m)', 15000, 'TKJ', 45, 'Tersedia'),
  Product(4, 'Flash Drive 32GB', 45000, 'TKJ', 0, 'Habis'),
  Product(5, 'Modul LCD 16x2', 35000, 'Elektronika', 8, 'Tersedia'),
  Product(6, 'Resistor Set 100pcs', 20000, 'Elektronika', 20, 'Tersedia'),
];

class HomeSiswaScreen extends StatefulWidget {
  final void Function(String) go;
  final VoidCallback onLoginRequest;
  const HomeSiswaScreen({
    super.key,
    required this.go,
    required this.onLoginRequest,
  });

  @override
  State<HomeSiswaScreen> createState() => _HomeSiswaScreenState();
}

class _HomeSiswaScreenState extends State<HomeSiswaScreen> {
  String cat = 'Semua';
  String q = '';

  @override
  Widget build(BuildContext context) {
    final filtered = mockProducts
        .where(
          (p) =>
              (cat == 'Semua' || p.category == cat) &&
              p.name.toLowerCase().contains(q.toLowerCase()),
        )
        .toList();
    final auth = Provider.of<AuthProvider>(context);
    final isAuth = auth.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Beranda'),
        actions: [
          TextButton(
            onPressed: widget.onLoginRequest,
            child: const Text('Masuk', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                onChanged: (v) => setState(() => q = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cari produk jurusan...',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['Semua', 'Elektronika', 'TKJ', 'RPL', 'Tata Boga']
                      .map((c) {
                        final active = c == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(c),
                            selected: active,
                            onSelected: (_) => setState(() => cat = c),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, i) {
                    final p = filtered[i];
                    return Card(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Image',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rp ${p.price}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                                Chip(label: Text(p.badge)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Action button (guarded)
                            isAuth
                                ? ElevatedButton(
                                    onPressed: () =>
                                        widget.go('siswa-checkout'),
                                    child: const Text('Beli'),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Login diperlukan'),
                                          content: const Text(
                                            'Anda perlu masuk untuk melakukan pembelian.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                              child: const Text('Batal'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                                widget.onLoginRequest();
                                              },
                                              child: const Text('Masuk'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Text('Login untuk Membeli'),
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
        ),
      ),
      bottomNavigationBar: null,
    );
  }
}
