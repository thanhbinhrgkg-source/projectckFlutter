class Member {
  final String id;
  final int roleId;
  final String? roleName;
  final String email;
  final String password;
  final String givenName;
  final String surname;
  Member({
    required this.id,
    required this.roleId,
    required this.roleName,
    required this.email,
    required this.password,
    required this.givenName,
    required this.surname,
  });
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      roleId: map['roleId'],
      roleName: map.containsKey('roleName') ? map['roleName'] : null,
      email: map['email'],
      password: map['password'],
      givenName: map['givenName'],
      surname: map['surname'] ?? '',
    );
  }
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'roleId': roleId,
      'email': email,
      'password': password,
      'givenName': givenName,
      'surname': surname,
    };
  }
}
