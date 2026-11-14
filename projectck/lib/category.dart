class Category {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final int productCount;
  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.productCount,
  });
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      productCount: map['productCount'] ?? 0,
    );
  }
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'productCount': productCount,
    };
  }
}
