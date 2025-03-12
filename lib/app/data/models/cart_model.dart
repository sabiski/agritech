import 'package:get/get.dart';

class CartItemModel {
  final String productId;
  final String productName;
  final double unitPrice;
  final String unit;
  final String? imageUrl;
  int quantity;
  final String sellerId;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.unit,
    this.imageUrl,
    required this.quantity,
    required this.sellerId,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': productName,
    'unit_price': unitPrice,
    'unit': unit,
    'image_url': imageUrl,
    'quantity': quantity,
    'seller_id': sellerId,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    productId: json['product_id'] as String,
    productName: json['product_name'] as String,
    unitPrice: (json['unit_price'] as num).toDouble(),
    unit: json['unit'] as String,
    imageUrl: json['image_url'] as String?,
    quantity: json['quantity'] as int,
    sellerId: json['seller_id'] as String,
  );

  CartItemModel copyWith({
    String? productId,
    String? productName,
    double? unitPrice,
    String? unit,
    String? imageUrl,
    int? quantity,
    String? sellerId,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      sellerId: sellerId ?? this.sellerId,
    );
  }
}

class CartModel {
  final items = <CartItemModel>[].obs;

  CartModel();

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  Map<String, List<CartItemModel>> get itemsBySeller {
    final map = <String, List<CartItemModel>>{};
    for (final item in items) {
      if (!map.containsKey(item.sellerId)) {
        map[item.sellerId] = [];
      }
      map[item.sellerId]!.add(item);
    }
    return map;
  }

  void addItem(CartItemModel item) {
    final existingItemIndex = items.indexWhere((i) => i.productId == item.productId);
    if (existingItemIndex != -1) {
      items[existingItemIndex].quantity += item.quantity;
    } else {
      items.add(item);
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.productId == productId);
  }

  void updateItemQuantity(String productId, int newQuantity) {
    final itemIndex = items.indexWhere((item) => item.productId == productId);
    if (itemIndex != -1) {
      items[itemIndex].quantity = newQuantity;
    }
  }

  void clear() {
    items.clear();
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
  };

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final cart = CartModel();
    final itemsList = json['items'] as List<dynamic>;
    cart.items.addAll(
      itemsList.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)),
    );
    return cart;
  }
} 