import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/app_shell.dart';
import 'presentation/providers/auth_provider.dart';
import 'core/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider.create(),
      child: MaterialApp(
        title: 'Katalog App',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const AppShell(),
      ),
    );
  }
}
