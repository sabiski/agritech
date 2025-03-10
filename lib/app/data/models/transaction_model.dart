import 'package:get/get.dart';

enum TransactionType {
  income,
  expense
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String farmerId;

  TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.farmerId,
  });

  // Convertir le modèle en Map pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'farmer_id': farmerId,
    };
  }

  // Créer une instance à partir d'un Map
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      category: json['category'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      farmerId: json['farmer_id'],
    );
  }

  // Copier l'instance avec des modifications
  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    String? category,
    double? amount,
    DateTime? date,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? farmerId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      farmerId: farmerId ?? this.farmerId,
    );
  }
} 