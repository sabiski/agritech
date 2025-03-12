class CartItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String sellerId;
  final String? imageUrl;
  final String unit;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.sellerId,
    required this.unit,
    this.imageUrl,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'seller_id': sellerId,
      'unit': unit,
      'image_url': imageUrl,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      sellerId: json['seller_id'] as String,
      unit: json['unit'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
} 