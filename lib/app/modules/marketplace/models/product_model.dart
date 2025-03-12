enum ProductStatus {
  available('disponible'),
  outOfStock('rupture de stock'),
  discontinued('discontinué');

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
  agricultural('Produits agricoles'),
  input('Intrants');

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
  seeds('Semences'),
  pesticides('Pesticides'),
  tools('Outils'),
  other('Autre');

  final String value;
  const ProductCategory(this.value);
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int quantity;
  final List<String> imageUrls;
  final String location;
  final String sellerId;
  final ProductStatus status;
  final ProductType type;
  final ProductCategory category;
  final DateTime createdAt;
  final bool isPromoted;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.imageUrls,
    required this.location,
    required this.sellerId,
    required this.status,
    required this.type,
    required this.category,
    required this.createdAt,
    this.isPromoted = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      quantity: json['quantity'] as int,
      imageUrls: (json['image_urls'] as List<dynamic>).cast<String>(),
      location: json['location'] as String,
      sellerId: json['seller_id'] as String,
      status: ProductStatus.fromString(json['status'] as String),
      type: ProductType.fromString(json['type'] as String),
      category: ProductCategory.values.firstWhere(
        (category) => category.value == json['category'],
        orElse: () => ProductCategory.other,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      isPromoted: json['is_promoted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'image_urls': imageUrls,
      'location': location,
      'seller_id': sellerId,
      'status': status.value,
      'type': type.value,
      'category': category.value,
      'created_at': createdAt.toIso8601String(),
      'is_promoted': isPromoted,
    };
  }
} 