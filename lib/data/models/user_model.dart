// Placeholder: User data model (DTO)

enum UserRole { siswa, admin, superAdmin }

class UserModel {
  final String id;
  final String email;
  final String? name;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.role,
  });
}
