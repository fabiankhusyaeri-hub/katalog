// Placeholder: domain User entity

enum Role { siswa, admin, superAdmin }

class User {
  final String id;
  final String email;
  final String? name;
  final Role role;

  User({required this.id, required this.email, this.name, required this.role});
}
