class OrderStatus {
  final int id;
  final String name;
  OrderStatus({required this.id, required this.name});
  factory OrderStatus.fromMap(Map<String, dynamic> map) {
    return OrderStatus(id: map['id'], name: map['name']);
  }
  Map<String, Object?> toMap() {
    return {'id': id, 'name': name};
  }
}
