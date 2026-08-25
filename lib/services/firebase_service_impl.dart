import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/user_model.dart';

class FirebaseServiceImpl {
  static final FirebaseServiceImpl _instance = FirebaseServiceImpl._internal();
  factory FirebaseServiceImpl() => _instance;
  FirebaseServiceImpl._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _initialized = true;
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    final cred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fb.User? u = cred.user;
    if (u == null) throw Exception('Failed to sign in');

    final role = await getUserRole(u.uid);
    return UserModel(
      id: u.uid,
      email: u.email ?? email,
      name: u.displayName,
      role: role,
    );
  }

  Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
  }

  Future<UserRole> getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      if (data == null) return UserRole.siswa;
      final r = (data['role'] ?? 'siswa') as String;
      if (r == 'admin') return UserRole.admin;
      if (r == 'super_admin' || r == 'superAdmin') return UserRole.superAdmin;
      return UserRole.siswa;
    } catch (_) {
      return UserRole.siswa;
    }
  }

  fb.User? get currentUser => fb.FirebaseAuth.instance.currentUser;
}
