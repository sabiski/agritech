import 'cart_item_model.dart';

class CartModel {
  final List<CartItemModel> items;

  CartModel({List<CartItemModel>? items}) : items = items ?? [];

  void addItem(CartItemModel item) {
    final existingItemIndex = items.indexWhere((i) => i.productId == item.productId);
    if (existingItemIndex != -1) {
      items[existingItemIndex] = CartItemModel(
        productId: item.productId,
        productName: item.productName,
        quantity: items[existingItemIndex].quantity + item.quantity,
        unitPrice: item.unitPrice,
        sellerId: item.sellerId,
        unit: item.unit,
        imageUrl: item.imageUrl,
      );
    } else {
      items.add(item);
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.productId == productId);
  }

  void updateItemQuantity(String productId, int quantity) {
    final index = items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = CartItemModel(
          productId: items[index].productId,
          productName: items[index].productName,
          quantity: quantity,
          unitPrice: items[index].unitPrice,
          sellerId: items[index].sellerId,
          unit: items[index].unit,
          imageUrl: items[index].imageUrl,
        );
      }
    }
  }

  void clear() {
    items.clear();
  }

  double get total {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

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

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
} 