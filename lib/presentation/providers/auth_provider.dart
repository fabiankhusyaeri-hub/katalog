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

  Future<void> login({required String email, required String password}) async {
    try {
      final u = await _loginUseCase.call(email: email, password: password);
      user = u;
      status = AuthStatus.authenticated;
      notifyListeners();
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
    } catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }
}
