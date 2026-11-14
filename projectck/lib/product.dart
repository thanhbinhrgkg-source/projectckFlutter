class Product {
  final int? id;
  final int categoryId;
  final String? categoryName;
  final String name;
  final String description;
  final double price;
  final int quota;
  final String imageUrl;
  final String? createdDate;
  Product({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.price,
    required this.quota,
    required this.imageUrl,
    required this.createdDate,
  });
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      name: map['name'],
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      quota: map['quota'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      createdDate: map['createdDate'],
    );
  }
  Map<String, String> toForm() {
    return {
      'categoryId': categoryId.toString(),
      'name': name,
      'description': description,
      'price': price.round().toString(),
      'quota': quota.toString(),
    };
  }
}
