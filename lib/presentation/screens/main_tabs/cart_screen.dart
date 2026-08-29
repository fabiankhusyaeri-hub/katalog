import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (c, i) {
                      final it = cart.items[i];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(it.title),
                          subtitle: Text('Rp${it.price} x ${it.quantity}'),
                          trailing: Text('Rp${it.price * it.quantity}'),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total: Rp${cart.totalAmount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final rootContext = context;
                                final authProvider = Provider.of<AuthProvider>(
                                  rootContext,
                                  listen: false,
                                );
                                final messenger = ScaffoldMessenger.of(
                                  rootContext,
                                );
                                final navigator = Navigator.of(rootContext);
                                final user = authProvider.user;
                                if (user == null) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Harap login terlebih dahulu',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final orderId = await cart.checkout(user.id);
                                if (!rootContext.mounted) return;
                                if (orderId != null) {
                                  showDialog(
                                    context: rootContext,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Checkout Berhasil'),
                                      content: Text(
                                        'Order dibuat: $orderId. Lanjutkan pembayaran QRIS.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => navigator.pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal membuat order'),
                                    ),
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('Checkout (QRIS)'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
