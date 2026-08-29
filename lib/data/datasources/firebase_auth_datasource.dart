import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

class FirebaseAuthDataSource {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<UserModel> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fb.User? u = cred.user;
    if (u == null) throw Exception('Sign-in failed');

    final role = await getUserRole(u.uid);
    return UserModel(
      id: u.uid,
      email: u.email ?? email,
      name: u.displayName,
      role: role,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserRole> getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      final r = ((data?['role'] as String?) ?? 'siswa').trim().toLowerCase();

      if (r == 'super_admin' ||
          r == 'superadmin' ||
          r == 'super admin' ||
          r == 'hubin') {
        return UserRole.superAdmin;
      }
      if (r == 'admin' || r == 'administrator') return UserRole.admin;
      return UserRole.siswa;
    } catch (e) {
      return UserRole.siswa;
    }
  }

  Future<UserModel> register(
    String email,
    String password,
    UserRole role, {
    String? name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fb.User? u = cred.user;
    if (u == null) throw Exception('Register failed');
    // store role in firestore
    // store role as snake_case strings for backward compatibility
    String roleStr = 'siswa';
    if (role == UserRole.admin) roleStr = 'admin';
    if (role == UserRole.superAdmin) roleStr = 'super_admin';
    await FirebaseFirestore.instance.collection('users').doc(u.uid).set({
      'role': roleStr,
      'name': name,
    });
    return UserModel(
      id: u.uid,
      email: u.email ?? email,
      name: name,
      role: role,
    );
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel> signInWithGoogle() async {
    // web/mobile Google Sign-In integration
    final google = GoogleSignIn();
    final account = await google.signIn();
    if (account == null) throw Exception('Google sign-in aborted');
    final googleAuth = await account.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    final fb.User? u = result.user;
    if (u == null) throw Exception('Google sign-in failed');
    final role = await getUserRole(u.uid);
    return UserModel(
      id: u.uid,
      email: u.email ?? account.email,
      name: u.displayName ?? account.displayName,
      role: role,
    );
  }
}
