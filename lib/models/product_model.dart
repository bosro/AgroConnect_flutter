class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> images;
  final String unit;
  final int stock;
  final String farmerId;
  final String farmerName;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final bool isOrganic;
  final String location;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    required this.unit,
    required this.stock,
    required this.farmerId,
    required this.farmerName,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    this.isOrganic = false,
    required this.location,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      unit: map['unit'] ?? '',
      stock: map['stock'] ?? 0,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      isOrganic: map['isOrganic'] ?? false,
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'images': images,
      'unit': unit,
      'stock': stock,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'isOrganic': isOrganic,
      'location': location,
    };
  }
}