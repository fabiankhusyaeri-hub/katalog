// Placeholder: abstract AuthRepository

import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<void> logout();
  Future<User> register({
    required String email,
    required String password,
    required Role role,
    String? name,
  });
  Future<void> resetPassword({required String email});
  Future<User> signInWithGoogle();
}
