import 'product_model.dart';

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final String unit;
  final double unitPrice;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
    );
  }
} 