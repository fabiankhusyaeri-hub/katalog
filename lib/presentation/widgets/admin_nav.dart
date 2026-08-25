import 'package:flutter/material.dart';

class AdminNav extends StatelessWidget {
  final String active;
  final void Function(String) go;
  const AdminNav({super.key, required this.active, required this.go});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              [
                    _item('admin-dashboard', Icons.bar_chart, 'Dashboard'),
                    _item('admin-products', Icons.inventory_2, 'Produk'),
                    _item('admin-scanner', Icons.qr_code_scanner, 'Scanner'),
                    _item('admin-add-user', Icons.group_add, 'Pengguna'),
                  ]
                  .map(
                    (w) =>
                        GestureDetector(onTap: () => go(w.key), child: w.value),
                  )
                  .toList(),
        ),
      ),
    );
  }

  MapEntry<String, Widget> _item(String key, IconData icon, String label) {
    final activeColor = key == active ? Colors.purple : Colors.grey.shade600;
    return MapEntry(
      key,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: activeColor),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: activeColor, fontSize: 11)),
        ],
      ),
    );
  }
}
