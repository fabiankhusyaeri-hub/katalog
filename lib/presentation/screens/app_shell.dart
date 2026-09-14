import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../../domain/entities/user.dart' as domain;
import 'generic_screen.dart';
import 'welcome_screen.dart';
// widget imports removed (unused) to clean warnings
import 'login/login_screen.dart';
// role-specific login screens unused (we use unified login)
// home_siswa_screen unused; replaced by MainNavigationScreen
// import 'home/home_admin_screen.dart';
import 'admin/admin_dashboard.dart';
import 'admin/admin_products.dart';
import 'admin/admin_users.dart';
import 'home/home_super_admin_screen.dart';
import 'main_navigation_screen.dart';
// super admin home unused currently

enum AppScreen {
  welcome,
  login,
  siswaHome,
  siswaKatalog,
  siswaPesanan,
  siswaProfil,
  siswaCheckout,
  siswaQris,
  adminDashboard,
  adminScanner,
  adminAddUser,
  adminProducts,
  hubinDashboard,
  hubinAdmins,
  hubinReports,
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppScreen screen = AppScreen.welcome;
  final List<AppScreen> history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      if (!mounted) return;

      setState(() {
        screen = hasSeenOnboarding ? AppScreen.login : AppScreen.welcome;
      });

      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.restoreSession();
    });
  }

  void go(AppScreen to) {
    setState(() {
      history.add(screen);
      screen = to;
    });
  }

  void back() {
    setState(() {
      if (history.isNotEmpty) {
        screen = history.removeLast();
      }
    });
  }

  AppScreen _effectiveScreen() {
    final auth = Provider.of<AuthProvider>(context);
    AppScreen effective = screen;
    if (auth.status == AuthStatus.authenticated && auth.user != null) {
      final r = auth.user!.role;
      if (r == domain.Role.superAdmin) {
        effective = AppScreen.hubinDashboard;
      } else if (r == domain.Role.admin) {
        effective = AppScreen.adminDashboard;
      } else if (screen == AppScreen.welcome || screen == AppScreen.login) {
        effective = AppScreen.siswaHome;
      }
    }
    return effective;
  }

  Widget renderScreen() {
    final effective = _effectiveScreen();

    switch (effective) {
      case AppScreen.welcome:
        return WelcomeScreenWidget(
          onEnter: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('seen_onboarding', true);
            if (!mounted) return;
            go(AppScreen.login);
          },
        );
      case AppScreen.login:
        return LoginScreen(
          go: (s) {
            if (s == 'siswa') go(AppScreen.siswaHome);
            if (s == 'admin') go(AppScreen.adminDashboard);
            if (s == 'hubin' || s == 'superAdmin') go(AppScreen.hubinDashboard);
          },
          back: back,
        );
      case AppScreen.siswaHome:
        return const MainNavigationScreen();
      case AppScreen.siswaKatalog:
        return GenericScreen(
          title: 'Katalog Produk - Siswa',
          onLogin: () => go(AppScreen.login),
        );
      case AppScreen.siswaPesanan:
        return GenericScreen(
          title: 'Pesanan Saya',
          onLogin: () => go(AppScreen.login),
        );
      case AppScreen.siswaProfil:
        return GenericScreen(
          title: 'Profil Saya',
          onLogin: () => go(AppScreen.login),
        );
      case AppScreen.siswaCheckout:
        return GenericScreen(
          title: 'Checkout',
          onLogin: () => go(AppScreen.login),
          child: ElevatedButton(
            onPressed: () => go(AppScreen.siswaQris),
            child: const Text('Bayar (QRIS)'),
          ),
        );
      case AppScreen.siswaQris:
        return GenericScreen(
          title: 'QRIS Pembayaran',
          onLogin: () => go(AppScreen.login),
        );
      case AppScreen.adminDashboard:
        return AdminDashboardScreen();
      case AppScreen.adminScanner:
        return GenericScreen(
          title: 'Scanner',
          onLogin: () => go(AppScreen.login),
        );
      case AppScreen.adminAddUser:
        return AdminUsersScreen();
      case AppScreen.adminProducts:
        return AdminProductsScreen();
      case AppScreen.hubinDashboard:
        return const HomeSuperAdminScreen();
      case AppScreen.hubinAdmins:
        return GenericScreen(
          title: 'Kelola Admin',
          onLogin: () => go(AppScreen.login),
        );
      case AppScreen.hubinReports:
        return GenericScreen(
          title: 'Laporan',
          onLogin: () => go(AppScreen.login),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = _effectiveScreen();

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(currentScreen),
          child: renderScreen(),
        ),
      ),
    );
  }
}
