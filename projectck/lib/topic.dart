class Topic {
  final int id;
  final String name;
  final String description;
  Topic({required this.id, required this.name, required this.description});
  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }
  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }
}
