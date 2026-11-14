class Cart {
  final int? id;
  final String memberId;
  final int productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;
  Cart({
    required this.id,
    required this.memberId,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });
  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'],
      memberId: map['memberId'],
      productId: map['productId'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity'],
    );
  }
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  double get amount => price * quantity;
}
