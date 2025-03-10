import 'package:get/get.dart';

enum TaskStatus {
  pending,
  inProgress,
  completed,
  overdue
}

enum TaskPriority {
  low,
  medium,
  high
}

class EmployeeTaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final TaskPriority priority;
  final String employeeId;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.employeeId,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convertir le modèle en Map pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'employee_id': employeeId,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Créer une instance à partir d'un Map
  factory EmployeeTaskModel.fromJson(Map<String, dynamic> json) {
    return EmployeeTaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
      ),
      employeeId: json['employee_id'],
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
} 