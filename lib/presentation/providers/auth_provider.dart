import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../../domain/entities/user.dart' as domain;
import '../../domain/usecases/login_usecase.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final FirebaseAuthDataSource _dataSource;

  domain.User? user;
  AuthStatus status = AuthStatus.unknown;

  AuthProvider._(this._loginUseCase, this._dataSource);

  factory AuthProvider.create() {
    final ds = FirebaseAuthDataSource();
    final repo = AuthRepositoryImpl(ds);
    final usecase = LoginUseCase(repo);
    return AuthProvider._(usecase, ds);
  }

  Future<void> restoreSession() async {
    final current = fb.FirebaseAuth.instance.currentUser;
    if (current == null) {
      user = null;
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final role = await _dataSource.getUserRole(current.uid);
      final mapped = switch (role) {
        UserRole.admin => domain.Role.admin,
        UserRole.superAdmin => domain.Role.superAdmin,
        _ => domain.Role.siswa,
      };

      user = domain.User(
        id: current.uid,
        email: current.email ?? '',
        name: current.displayName,
        role: mapped,
      );
      status = AuthStatus.authenticated;
      notifyListeners();
    } catch (_) {
      user = null;
      status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  String _normalizeRoleName(String role) {
    final normalized = role.trim();
    if (normalized.toLowerCase() == 'superadmin') return 'super_admin';
    if (normalized.toLowerCase() == 'super_admin') return 'super_admin';
    if (normalized.toLowerCase() == 'hubin') return 'super_admin';
    return normalized.toLowerCase();
  }

  Future<void> _recordAccessLog({
    required String email,
    required String role,
    required String action,
    required String method,
    String? description,
  }) async {
    try {
      final uid = fb.FirebaseAuth.instance.currentUser?.uid ?? user?.id ?? '';
      await FirebaseFirestore.instance.collection('access_audit').add({
        'userId': uid,
        'email': email,
        'role': _normalizeRoleName(role),
        'action': action,
        'method': method,
        'description': description ?? 'Akses sistem',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // ignore logging errors; app should still work if audit storage is unavailable
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final u = await _loginUseCase.call(email: email, password: password);
      user = u;
      status = AuthStatus.authenticated;
      notifyListeners();
      await _recordAccessLog(
        email: email,
        role: u.role.name,
        action: 'login',
        method: 'email_password',
        description: 'Login berhasil melalui email dan password',
      );
    } catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _loginUseCase.repository.logout();
    } finally {
      user = null;
      status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required domain.Role role,
    String? name,
  }) async {
    try {
      final u = await _loginUseCase.repository.register(
        email: email,
        password: password,
        role: role,
        name: name,
      );
      user = u;
      status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _loginUseCase.repository.resetPassword(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final u = await _loginUseCase.repository.signInWithGoogle();
      user = u;
      status = AuthStatus.authenticated;
      notifyListeners();
      await _recordAccessLog(
        email: u.email,
        role: u.role.name,
        action: 'login',
        method: 'google',
        description: 'Login berhasil menggunakan Google',
      );
    } catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }
}
