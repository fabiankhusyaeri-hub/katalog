import 'package:flutter/material.dart';

import '../../domain/entities/user.dart' as domain;
import '../../domain/usecases/login_usecase.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  domain.User? user;
  AuthStatus status = AuthStatus.unknown;

  AuthProvider._(this._loginUseCase);

  factory AuthProvider.create() {
    final ds = FirebaseAuthDataSource();
    final repo = AuthRepositoryImpl(ds);
    final usecase = LoginUseCase(repo);
    return AuthProvider._(usecase);
  }

  Future<void> login({
    required String email,
    required String password,
    required domain.Role role,
  }) async {
    try {
      final u = await _loginUseCase.call(
        email: email,
        password: password,
        role: role,
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

  Future<void> logout() async {
    // delegate to repository via usecase's repo
    // simple approach: rebuild provider
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
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
