import 'package:flutter/material.dart';

class SiswaNav extends StatelessWidget {
  final String active;
  final void Function(String) go;
  const SiswaNav({super.key, required this.active, required this.go});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              [
                    _item('siswa-home', Icons.home, 'Beranda'),
                    _item('siswa-katalog', Icons.grid_view, 'Katalog'),
                    _item('siswa-pesanan', Icons.shopping_bag, 'Pesanan'),
                    _item('siswa-profil', Icons.person, 'Profil'),
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
    final activeColor = key == active ? Colors.blue : Colors.grey.shade600;
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
