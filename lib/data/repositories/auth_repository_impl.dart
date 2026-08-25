import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Future<domain.User> login({
    required String email,
    required String password,
    required domain.Role role,
  }) async {
    final UserModel u = await _ds.signIn(email, password);
    // map data model role to domain.Role (basic mapping)
    domain.Role mapped;
    switch (u.role) {
      case UserRole.admin:
        mapped = domain.Role.admin;
        break;
      case UserRole.superAdmin:
        mapped = domain.Role.superAdmin;
        break;
      default:
        mapped = domain.Role.siswa;
    }

    return domain.User(id: u.id, email: u.email, name: u.name, role: mapped);
  }

  @override
  Future<void> logout() => _ds.signOut();

  @override
  Future<domain.User> register({
    required String email,
    required String password,
    required domain.Role role,
    String? name,
  }) async {
    // map domain.Role to UserRole
    UserRole r;
    switch (role) {
      case domain.Role.admin:
        r = UserRole.admin;
        break;
      case domain.Role.superAdmin:
        r = UserRole.superAdmin;
        break;
      default:
        r = UserRole.siswa;
    }
    final um = await _ds.register(email, password, r, name: name);
    final mapped = domain.User(
      id: um.id,
      email: um.email,
      name: um.name,
      role: role,
    );
    return mapped;
  }

  @override
  Future<void> resetPassword({required String email}) =>
      _ds.resetPassword(email);

  @override
  Future<domain.User> signInWithGoogle() async {
    final um = await _ds.signInWithGoogle();
    domain.Role mapped;
    switch (um.role) {
      case UserRole.admin:
        mapped = domain.Role.admin;
        break;
      case UserRole.superAdmin:
        mapped = domain.Role.superAdmin;
        break;
      default:
        mapped = domain.Role.siswa;
    }
    return domain.User(id: um.id, email: um.email, name: um.name, role: mapped);
  }
}
