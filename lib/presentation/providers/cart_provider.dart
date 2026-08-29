import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// domain user import not needed here

class CartItem {
  final int id;
  final String title;
  final int price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  String? _currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartItem> get items => _items.values.toList();

  int get totalCount => _items.values.fold(0, (s, i) => s + i.quantity);

  int get totalAmount =>
      _items.values.fold(0, (s, i) => s + i.price * i.quantity);

  void addItem(int id, String title, int price) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
    } else {
      _items[id] = CartItem(id: id, title: title, price: price);
    }
    notifyListeners();
    _saveIfLinked();
  }

  void removeItem(int id) {
    _items.remove(id);
    notifyListeners();
    _saveIfLinked();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveIfLinked();
  }

  void _saveIfLinked() {
    if (_currentUserId != null) {
      saveForUser(_currentUserId!);
    }
  }

  Future<void> saveForUser(String userId) async {
    final data = _items.values
        .map(
          (i) => {
            'id': i.id,
            'title': i.title,
            'price': i.price,
            'quantity': i.quantity,
          },
        )
        .toList();
    try {
      await _firestore.collection('carts').doc(userId).set({
        'items': data,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore errors for now
    }
  }

  Future<void> loadForUser(String userId) async {
    if (_currentUserId == userId) return; // already loaded for this user
    _currentUserId = userId;
    try {
      final doc = await _firestore.collection('carts').doc(userId).get();
      if (doc.exists) {
        final raw = doc.data();
        final items = (raw?['items'] as List<dynamic>?) ?? [];
        _items.clear();
        for (final it in items) {
          final id = (it['id'] as num).toInt();
          _items[id] = CartItem(
            id: id,
            title: it['title'] as String,
            price: (it['price'] as num).toInt(),
            quantity: (it['quantity'] as num).toInt(),
          );
        }
        notifyListeners();
      }
    } catch (e) {
      // ignore
    }
  }

  Future<String?> checkout(String userId) async {
    if (_items.isEmpty) return null;
    final orderData = {
      'userId': userId,
      'items': _items.values
          .map(
            (i) => {
              'id': i.id,
              'title': i.title,
              'price': i.price,
              'quantity': i.quantity,
            },
          )
          .toList(),
      'total': totalAmount,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    };
    try {
      final docRef = await _firestore.collection('orders').add(orderData);
      // clear cart after creating order
      clear();
      // remove cart doc
      await _firestore.collection('carts').doc(userId).delete();
      return docRef.id;
    } catch (e) {
      return null;
    }
  }
}
