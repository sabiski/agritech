import 'package:uuid/uuid.dart';

enum OrderStatus {
  pending,    // En attente de confirmation
  confirmed,  // Confirmée par le vendeur
  shipped,    // Expédiée
  delivered,  // Livrée
  cancelled,  // Annulée
  refunded    // Remboursée
}

class OrderItemModel {
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  }) : totalPrice = quantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      unitPrice: json['unit_price'].toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final double totalAmount;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? trackingNumber;
  final String? notes;

  OrderModel({
    String? id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.status,
    required this.totalAmount,
    this.shippingAddress,
    this.paymentMethod,
    this.paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.trackingNumber,
    this.notes,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.toString().split('.').last,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tracking_number': trackingNumber,
      'notes': notes,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      buyerId: json['buyer_id'],
      sellerId: json['seller_id'],
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      totalAmount: json['total_amount'].toDouble(),
      shippingAddress: json['shipping_address'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      trackingNumber: json['tracking_number'],
      notes: json['notes'],
    );
  }

  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    List<OrderItemModel>? items,
    OrderStatus? status,
    double? totalAmount,
    String? shippingAddress,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? trackingNumber,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      items: items ?? this.items,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
    );
  }
} 