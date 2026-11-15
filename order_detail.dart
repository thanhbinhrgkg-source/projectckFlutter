class OrderDetail {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final String imageUrl;
  final int quantity;
  final double price;
  OrderDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });
  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      id: map['id'],
      orderId: map['orderId'],
      productId: map['productId'],
      productName: map['productName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
    );
  }

  double get amount => price * quantity;
}
