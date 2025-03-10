import 'package:get/get.dart';

enum EmployeeStatus {
  active,
  inactive
}

class EmployeeModel {
  final String id;
  final String fullName;
  final String position;
  final double salary;
  final String phoneNumber;
  final String email;
  final EmployeeStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String farmerId;

  EmployeeModel({
    required this.id,
    required this.fullName,
    required this.position,
    required this.salary,
    required this.phoneNumber,
    required this.email,
    required this.status,
    required this.startDate,
    this.endDate,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.farmerId,
  });

  // Convertir le modèle en Map pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'position': position,
      'salary': salary,
      'phone_number': phoneNumber,
      'email': email,
      'status': status.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'address': address,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'farmer_id': farmerId,
    };
  }

  // Créer une instance à partir d'un Map
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      fullName: json['full_name'],
      position: json['position'],
      salary: json['salary'].toDouble(),
      phoneNumber: json['phone_number'],
      email: json['email'],
      status: EmployeeStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      address: json['address'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      farmerId: json['farmer_id'],
    );
  }
} 