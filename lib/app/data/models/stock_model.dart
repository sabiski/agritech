import 'package:get/get.dart';

class StockModel {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime expirationDate;
  final double price;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String farmerId;

  StockModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expirationDate,
    required this.price,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.farmerId,
  });

  // Convertir le modèle en Map pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiration_date': expirationDate.toIso8601String(),
      'price': price,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'farmer_id': farmerId,
    };
  }

  // Créer une instance à partir d'un Map
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      expirationDate: DateTime.parse(json['expiration_date']),
      price: json['price'].toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      farmerId: json['farmer_id'],
    );
  }

  // Copier l'instance avec des modifications
  StockModel copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    DateTime? expirationDate,
    double? price,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? farmerId,
  }) {
    return StockModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expirationDate: expirationDate ?? this.expirationDate,
      price: price ?? this.price,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      farmerId: farmerId ?? this.farmerId,
    );
  }

  // Vérifier si le produit est bientôt périmé (moins de 7 jours)
  bool get isNearExpiration {
    final daysUntilExpiration = expirationDate.difference(DateTime.now()).inDays;
    return daysUntilExpiration <= 7 && daysUntilExpiration > 0;
  }

  // Vérifier si le produit est périmé
  bool get isExpired {
    return DateTime.now().isAfter(expirationDate);
  }

  // Vérifier si le stock est bas (moins de 20% de la quantité initiale)
  bool get isLowStock {
    return quantity <= 20; // À ajuster selon vos besoins
  }

  // Obtenir le statut du stock
  String get status {
    if (isExpired) return 'Périmé';
    if (isNearExpiration) return 'Bientôt périmé';
    if (isLowStock) return 'Stock bas';
    return 'En stock';
  }

  // Obtenir la couleur du statut
  String get statusColor {
    if (isExpired) return 'red';
    if (isNearExpiration) return 'orange';
    if (isLowStock) return 'yellow';
    return 'green';
  }
} 