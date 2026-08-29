import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SuperAdminOrderDetailScreen extends StatelessWidget {
  final String orderId;

  const SuperAdminOrderDetailScreen({super.key, required this.orderId});

  Future<Map<String, dynamic>> _loadOrder() async {
    final doc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();
    final data = doc.data() ?? {};
    final items = (data['items'] as List<dynamic>? ?? const []);
    return {
      'id': doc.id,
      'status': data['status'] ?? 'pending',
      'total': data['total'] ?? 0,
      'items': items,
      'createdAt': data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate()
          : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Order')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadOrder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data ?? {};
          final items = (order['items'] as List<dynamic>? ?? const []);
          final status = (order['status'] ?? 'pending').toString();
          final total = order['total'] ?? 0;
          final createdAt = order['createdAt'] as DateTime?;
          final dateText = createdAt != null
              ? createdAt.toLocal().toString()
              : 'Tanggal tidak tersedia';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['id']?.toString().substring(0, 8) ?? '---'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status'),
                          Chip(
                            label: Text(status),
                            backgroundColor: status.toLowerCase() == 'pending'
                                ? Colors.orange.shade100
                                : Colors.green.shade100,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Tanggal: $dateText'),
                      const SizedBox(height: 8),
                      Text('Total: Rp$total'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Daftar Produk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada item di order ini.'),
                  ),
                )
              else
                ...items.map((item) {
                  final itemMap = item is Map<String, dynamic>
                      ? item
                      : <String, dynamic>{};
                  final title = itemMap['title'] ?? 'Produk';
                  final qty = itemMap['quantity'] ?? 1;
                  final price = itemMap['price'] ?? 0;
                  return Card(
                    child: ListTile(
                      title: Text(title.toString()),
                      subtitle: Text('Qty: $qty'),
                      trailing: Text('Rp${price * qty}'),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
