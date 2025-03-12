import 'package:get/get.dart';
import 'order_item_model.dart';

enum OrderStatus {
  pending('en attente'),
  confirmed('confirmée'),
  inProgress('en cours'),
  delivered('livrée'),
  cancelled('annulée');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String sellerId;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final DateTime createdAt;
  final double total;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? paymentStatus;

  OrderModel({
    required this.id,
    required this.userId,
    required this.sellerId,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.total,
    this.shippingAddress,
    this.paymentMethod,
    this.paymentStatus,
  });

  String get date {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sellerId: json['seller_id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: OrderStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      total: (json['total'] as num).toDouble(),
      shippingAddress: json['shipping_address'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: json['payment_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'seller_id': sellerId,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'total': total,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
    };
  }
} 