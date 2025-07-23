class AdminModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin', 'super_admin'
  final List<String> permissions;
  final DateTime createdAt;

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'admin',
    this.permissions = const [],
    required this.createdAt,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'admin',
      permissions: List<String>.from(map['permissions'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'permissions': permissions,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}