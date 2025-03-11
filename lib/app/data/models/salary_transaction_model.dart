import 'package:get/get.dart';

class SalaryTransactionModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final double baseAmount;
  final double bonusAmount;
  final double totalAmount;
  final DateTime paymentDate;
  final String period; // ex: "2024-03"
  final String status; // "pending", "paid", "cancelled"
  final Map<String, dynamic>? performanceMetrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalaryTransactionModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.baseAmount,
    required this.bonusAmount,
    required this.totalAmount,
    required this.paymentDate,
    required this.period,
    required this.status,
    this.performanceMetrics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalaryTransactionModel.fromJson(Map<String, dynamic> json) {
    return SalaryTransactionModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      employeeName: json['employee_name'] as String? ?? 'Employé inconnu',
      baseAmount: (json['base_amount'] as num).toDouble(),
      bonusAmount: (json['bonus_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      period: json['period'] as String,
      status: json['status'] as String,
      performanceMetrics: json['performance_metrics'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'base_amount': baseAmount,
      'bonus_amount': bonusAmount,
      'total_amount': totalAmount,
      'payment_date': paymentDate.toIso8601String(),
      'period': period,
      'status': status,
      'performance_metrics': performanceMetrics,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 