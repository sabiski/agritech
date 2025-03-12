import 'package:uuid/uuid.dart';

enum ProductType {
  agricultural, // Produits agricoles
  input // Intrants (engrais, semences, équipements)
}

enum ProductStatus {
  available,
  outOfStock,
  hidden
}

class ProductModel {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final double price;
  final double quantity;
  final String unit; // kg, g, L, unité
  final ProductType type;
  final ProductStatus status;
  final String category;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String location;

  ProductModel({
    String? id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.type,
    required this.status,
    required this.category,
    required this.imageUrls,
    this.rating = 0.0,
    this.reviewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.location,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'category': category,
      'image_urls': imageUrls,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'location': location,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      sellerId: json['seller_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      type: ProductType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      status: ProductStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      category: json['category'],
      imageUrls: List<String>.from(json['image_urls']),
      rating: json['rating'].toDouble(),
      reviewCount: json['review_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      location: json['location'],
    );
  }

  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? description,
    double? price,
    double? quantity,
    String? unit,
    ProductType? type,
    ProductStatus? status,
    String? category,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
    );
  }
} 