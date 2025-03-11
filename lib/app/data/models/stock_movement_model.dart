enum MovementType {
  entry,
  exit
}

class StockMovementModel {
  final String id;
  final String stockItemId;
  final String? stockItemName;
  final MovementType type;
  final double quantity;
  final String? reason;
  final DateTime date;
  final DateTime createdAt;

  StockMovementModel({
    required this.id,
    required this.stockItemId,
    this.stockItemName,
    required this.type,
    required this.quantity,
    this.reason,
    required this.date,
    required this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'],
      stockItemId: json['stock_item_id'],
      stockItemName: json['stock_items'] != null ? json['stock_items']['name'] : null,
      type: MovementType.values.firstWhere(
        (e) => e.toString() == 'MovementType.${json['type']}',
      ),
      quantity: json['quantity'].toDouble(),
      reason: json['reason'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stock_item_id': stockItemId,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'reason': reason,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
} 