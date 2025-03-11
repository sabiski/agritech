import 'package:get/get.dart';

class SalaryTransactionModel {
  final String id;
  final String employeeId;
  final String? employeeName;
  final double amount;
  final double? bonus;
  final String? bonusReason;
  final DateTime paymentDate;
  final String period;
  final String status;
  final DateTime createdAt;

  SalaryTransactionModel({
    required this.id,
    required this.employeeId,
    this.employeeName,
    required this.amount,
    this.bonus,
    this.bonusReason,
    required this.paymentDate,
    required this.period,
    required this.status,
    required this.createdAt,
  });

  factory SalaryTransactionModel.fromJson(Map<String, dynamic> json) {
    return SalaryTransactionModel(
      id: json['id'],
      employeeId: json['employee_id'],
      employeeName: json['employees'] != null ? json['employees']['full_name'] : null,
      amount: json['amount'].toDouble(),
      bonus: json['bonus']?.toDouble(),
      bonusReason: json['bonus_reason'],
      paymentDate: DateTime.parse(json['payment_date']),
      period: json['period'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'amount': amount,
      'bonus': bonus,
      'bonus_reason': bonusReason,
      'payment_date': paymentDate.toIso8601String(),
      'period': period,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 