import 'package:flutter/material.dart';

class GenericScreen extends StatelessWidget {
  final String title;
  final Widget? child;
  final VoidCallback? onLogin;
  const GenericScreen({
    super.key,
    required this.title,
    this.child,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: Theme.of(context).primaryColor,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (onLogin != null)
                    TextButton(
                      onPressed: onLogin,
                      child: const Text(
                        'Masuk',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child:
                    child ?? Text(title, style: const TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
