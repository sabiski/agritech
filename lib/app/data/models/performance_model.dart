class PerformanceModel {
  final String id;
  final String employeeId;
  final String? employeeName;
  final double score;
  final int tasksCompleted;
  final int tasksAssigned;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;

  PerformanceModel({
    required this.id,
    required this.employeeId,
    this.employeeName,
    required this.score,
    required this.tasksCompleted,
    required this.tasksAssigned,
    this.notes,
    required this.date,
    required this.createdAt,
  });

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      id: json['id'],
      employeeId: json['employee_id'],
      employeeName: json['employees'] != null ? json['employees']['full_name'] : null,
      score: json['score'].toDouble(),
      tasksCompleted: json['tasks_completed'],
      tasksAssigned: json['tasks_assigned'],
      notes: json['notes'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'score': score,
      'tasks_completed': tasksCompleted,
      'tasks_assigned': tasksAssigned,
      'notes': notes,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
} 