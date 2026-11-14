class Role {
  static const Map<String, String> labels = {
    'member': 'Thành viên',
    'manager': 'Quản lý',
    'admin': 'Quản trị viên',
  };
  static const List<String> systemRoles = ['member', 'manager', 'admin'];
  final int id;
  final String name;
  final int memberCount;
  Role({required this.id, required this.name, this.memberCount = 0});
  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'],
      name: map['name'],
      memberCount: map['memberCount'] ?? 0,
    );
  }
  Map<String, Object?> toMap() {
    return {'id': id, 'name': name};
  }

  static String label(String? name) => labels[name] ?? name ?? '';
}
