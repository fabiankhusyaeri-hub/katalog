import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final bool light;
  const StatusBar({super.key, this.light = false});

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : Colors.black87;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 8),
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '09:41',
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
