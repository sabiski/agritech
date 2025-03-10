import 'package:get/get.dart';
import '../../../data/models/employee_task_model.dart';
import '../../../data/models/employee_model.dart';
import '../controllers/employee_controller.dart';

class EmployeeAnalyticsService extends GetxService {
  final EmployeeController _employeeController = Get.find<EmployeeController>();

  // Obtenir les tâches en retard pour un employé
  List<EmployeeTaskModel> getOverdueTasks(String employeeId) {
    final tasks = _employeeController.getEmployeeTasks(employeeId);
    final now = DateTime.now();
    return tasks.where((task) {
      return task.status != TaskStatus.completed && 
             task.dueDate.isBefore(now);
    }).toList();
  }

  // Calculer le taux de complétion des tâches
  double getTaskCompletionRate(String employeeId) {
    final tasks = _employeeController.getEmployeeTasks(employeeId);
    if (tasks.isEmpty) return 0.0;

    final completedTasks = tasks.where((task) => 
      task.status == TaskStatus.completed
    ).length;

    return completedTasks / tasks.length;
  }

  // Vérifier si un employé est inactif (pas de tâches complétées depuis 30 jours)
  bool isEmployeeInactive(String employeeId) {
    final tasks = _employeeController.getEmployeeTasks(employeeId);
    if (tasks.isEmpty) return true;

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final hasRecentActivity = tasks.any((task) {
      return task.status == TaskStatus.completed && 
             (task.completedAt?.isAfter(thirtyDaysAgo) ?? false);
    });

    return !hasRecentActivity;
  }

  // Obtenir les statistiques de performance
  Map<String, dynamic> getEmployeePerformanceStats(String employeeId) {
    final tasks = _employeeController.getEmployeeTasks(employeeId);
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Tâches des 30 derniers jours
    final recentTasks = tasks.where((task) => 
      task.createdAt.isAfter(thirtyDaysAgo)
    ).toList();

    // Tâches complétées à temps
    final completedOnTime = recentTasks.where((task) {
      return task.status == TaskStatus.completed &&
             (task.completedAt?.isBefore(task.dueDate) ?? false);
    }).length;

    // Tâches en retard
    final overdueTasks = recentTasks.where((task) {
      return task.status != TaskStatus.completed && 
             task.dueDate.isBefore(now);
    }).length;

    // Taux de complétion dans les délais
    final onTimeCompletionRate = recentTasks.isEmpty ? 
      0.0 : (completedOnTime / recentTasks.length);

    return {
      'total_tasks': recentTasks.length,
      'completed_on_time': completedOnTime,
      'overdue_tasks': overdueTasks,
      'on_time_completion_rate': onTimeCompletionRate,
      'is_inactive': isEmployeeInactive(employeeId),
    };
  }

  // Générer des notifications pour un employé
  List<Map<String, dynamic>> getEmployeeNotifications(String employeeId) {
    final notifications = <Map<String, dynamic>>[];
    final stats = getEmployeePerformanceStats(employeeId);
    final overdueTasks = getOverdueTasks(employeeId);

    // Notification pour l'inactivité
    if (stats['is_inactive']) {
      notifications.add({
        'type': 'warning',
        'title': 'Inactivité détectée',
        'message': 'Aucune tâche complétée depuis 30 jours',
        'icon': 'person_off',
      });
    }

    // Notification pour les tâches en retard
    if (overdueTasks.isNotEmpty) {
      notifications.add({
        'type': 'error',
        'title': 'Tâches en retard',
        'message': '${overdueTasks.length} tâche(s) en retard',
        'icon': 'warning',
      });
    }

    // Notification pour un bon taux de complétion
    if (stats['on_time_completion_rate'] > 0.8) {
      notifications.add({
        'type': 'success',
        'title': 'Excellente performance',
        'message': 'Taux de complétion dans les délais supérieur à 80%',
        'icon': 'star',
      });
    }

    return notifications;
  }
} 