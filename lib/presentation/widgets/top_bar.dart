import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBack;
  final Widget? right;
  final bool light;
  const TopBar({
    super.key,
    this.title,
    this.onBack,
    this.right,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(title!, style: TextStyle(fontWeight: FontWeight.w800))
          : null,
      centerTitle: true,
      backgroundColor: light
          ? Colors.transparent
          : Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: onBack != null
          ? IconButton(icon: Icon(Icons.arrow_back), onPressed: onBack)
          : null,
      actions: right != null
          ? [Padding(padding: EdgeInsets.only(right: 8), child: right!)]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
