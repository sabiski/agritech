class StockItemModel {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final double minQuantity;
  final String unit;
  final double unitPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StockItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minQuantity,
    required this.unit,
    required this.unitPrice,
    required this.createdAt,
    this.updatedAt,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'].toDouble(),
      minQuantity: json['min_quantity'].toDouble(),
      unit: json['unit'],
      unitPrice: json['unit_price'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'min_quantity': minQuantity,
      'unit': unit,
      'unit_price': unitPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 