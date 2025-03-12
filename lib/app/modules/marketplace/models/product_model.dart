enum ProductStatus {
  available('Disponible'),
  outOfStock('Rupture de stock'),
  discontinued('Arrêté');

  final String value;
  const ProductStatus(this.value);

  static ProductStatus fromString(String value) {
    return ProductStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProductStatus.available,
    );
  }
}

enum ProductType {
  agricultural('Produit agricole'),
  input('Intrant');

  final String value;
  const ProductType(this.value);

  static ProductType fromString(String value) {
    return ProductType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ProductType.agricultural,
    );
  }
}

enum ProductCategory {
  vegetables('Légumes'),
  fruits('Fruits'),
  cereals('Céréales'),
  tubers('Tubercules'),
  fertilizers('Engrais'),
  pesticides('Pesticides'),
  seeds('Semences'),
  tools('Outils'),
  other('Autre');

  final String value;
  const ProductCategory(this.value);

  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => ProductCategory.other,
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? promoPrice;
  final int quantity;
  final String unit;
  final ProductCategory category;
  final ProductType type;
  final ProductStatus status;
  final String sellerId;
  final List<String> imageUrls;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.promoPrice,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.type,
    required this.status,
    required this.sellerId,
    required this.imageUrls,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'promo_price': promoPrice,
      'quantity': quantity,
      'unit': unit,
      'category': category.toString().split('.').last,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'seller_id': sellerId,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      promoPrice: json['promo_price'] != null ? (json['promo_price'] as num).toDouble() : null,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      category: ProductCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => ProductCategory.other,
      ),
      type: ProductType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ProductType.agricultural,
      ),
      status: ProductStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ProductStatus.available,
      ),
      sellerId: json['seller_id'] as String,
      imageUrls: (json['image_urls'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? promoPrice,
    int? quantity,
    String? unit,
    ProductCategory? category,
    ProductType? type,
    ProductStatus? status,
    String? sellerId,
    List<String>? imageUrls,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      promoPrice: promoPrice ?? this.promoPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      type: type ?? this.type,
      status: status ?? this.status,
      sellerId: sellerId ?? this.sellerId,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 