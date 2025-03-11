import 'package:get/get.dart';

enum TransactionType {
  income,
  expense
}

class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final String? description;
  final DateTime date;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String farmerId;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.date,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.farmerId,
  });

  // Convertir le modèle en Map pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'farmer_id': farmerId,
    };
  }

  // Créer une instance à partir d'un Map
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: json['category'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      farmerId: json['farmer_id'] as String,
    );
  }

  // Copier l'instance avec des modifications
  TransactionModel copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? category,
    String? description,
    DateTime? date,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? farmerId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      farmerId: farmerId ?? this.farmerId,
    );
  }
} 