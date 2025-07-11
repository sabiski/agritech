import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/employee_task_model.dart';
import '../../../core/utils/helpers.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/salary_transaction_model.dart';
import '../../../data/models/performance_model.dart';

class EmployeeController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();
  
  // État observable
  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final RxList<EmployeeTaskModel> tasks = <EmployeeTaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedPosition = 'Tous'.obs;
  final RxString selectedStatus = 'Tous'.obs;
  final RxString error = ''.obs;
  
  // Filtres observables
  final RxList<String> positions = <String>['Tous'].obs;
  final RxList<String> statuses = <String>['Tous', 'Actif', 'Inactif'].obs;

  // Statistiques observables
  final RxDouble totalSalaries = 0.0.obs;
  final RxInt activeEmployees = 0.obs;
  final RxInt inactiveEmployees = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
    fetchTasks();
  }

  // Récupérer tous les employés
  Future<void> fetchEmployees() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await _supabase
          .from('employees')
          .select()
          .order('created_at', ascending: false);
      
      final List<EmployeeModel> employeesList = response
          .map<EmployeeModel>((json) => EmployeeModel.fromJson(json))
          .toList();
      
      employees.value = employeesList;
      
      // Mettre à jour les positions disponibles
      final uniquePositions = employeesList
          .map((employee) => employee.position)
          .toSet()
          .toList();
      positions.value = ['Tous', ...uniquePositions];

      // Calculer les statistiques
      _updateStats();
      
    } catch (e) {
      print('Error fetching employees: $e');
      error.value = 'Erreur lors du chargement des employés: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de charger les employés');
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer toutes les tâches
  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await _supabase
          .from('employee_tasks')
          .select()
          .order('due_date', ascending: true);
      
      print('Tasks response: $response');
      
      final List<EmployeeTaskModel> tasksList = response
          .map<EmployeeTaskModel>((json) => EmployeeTaskModel.fromJson(json))
          .toList();
      
      tasks.value = tasksList;
      
    } catch (e) {
      print('Error fetching tasks: $e');
      error.value = 'Erreur lors du chargement des tâches: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de charger les tâches');
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter un nouvel employé
  Future<void> addEmployee({
    required String fullName,
    required String position,
    required double salary,
    required String phoneNumber,
    required String email,
    required DateTime startDate,
    String? address,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final employee = EmployeeModel(
        id: _uuid.v4(),
        fullName: fullName,
        position: position,
        salary: salary,
        phoneNumber: phoneNumber,
        email: email,
        status: EmployeeStatus.active,
        startDate: startDate,
        address: address,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        farmerId: _supabase.auth.currentUser!.id,
      );
      
      await _supabase
          .from('employees')
          .insert(employee.toJson());
      
      await fetchEmployees();
      Get.back();
      showSuccessSnackbar('Succès', 'Employé ajouté avec succès');
      
    } catch (e) {
      print('Error adding employee: $e');
      error.value = 'Erreur lors de l\'ajout de l\'employé: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible d\'ajouter l\'employé');
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour un employé
  Future<void> updateEmployee(EmployeeModel employee) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _supabase
          .from('employees')
          .update(employee.toJson())
          .eq('id', employee.id);
      
      await fetchEmployees();
      Get.back();
      showSuccessSnackbar('Succès', 'Employé mis à jour avec succès');
      
    } catch (e) {
      print('Error updating employee: $e');
      error.value = 'Erreur lors de la mise à jour de l\'employé: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de mettre à jour l\'employé');
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un employé
  Future<void> deleteEmployee(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _supabase
          .from('employees')
          .delete()
          .eq('id', id);
      
      await fetchEmployees();
      showSuccessSnackbar('Succès', 'Employé supprimé avec succès');
      
    } catch (e) {
      print('Error deleting employee: $e');
      error.value = 'Erreur lors de la suppression de l\'employé: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de supprimer l\'employé');
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour le statut d'un employé
  Future<void> updateEmployeeStatus(String id, EmployeeStatus status) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final employee = employees.firstWhere((e) => e.id == id);
      final updatedEmployee = EmployeeModel(
        id: employee.id,
        fullName: employee.fullName,
        position: employee.position,
        salary: employee.salary,
        phoneNumber: employee.phoneNumber,
        email: employee.email,
        status: status,
        startDate: employee.startDate,
        endDate: status == EmployeeStatus.inactive ? DateTime.now() : null,
        address: employee.address,
        notes: employee.notes,
        createdAt: employee.createdAt,
        updatedAt: DateTime.now(),
        farmerId: employee.farmerId,
      );
      
      await updateEmployee(updatedEmployee);
      
    } catch (e) {
      print('Error updating employee status: $e');
      error.value = 'Erreur lors de la mise à jour du statut: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de mettre à jour le statut');
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer les employés
  List<EmployeeModel> get filteredEmployees {
    return employees.where((employee) {
      final matchesSearch = employee.fullName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                          employee.position.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesPosition = selectedPosition.value == 'Tous' || employee.position == selectedPosition.value;
      final matchesStatus = selectedStatus.value == 'Tous' ||
                          (selectedStatus.value == 'Actif' && employee.status == EmployeeStatus.active) ||
                          (selectedStatus.value == 'Inactif' && employee.status == EmployeeStatus.inactive);
      return matchesSearch && matchesPosition && matchesStatus;
    }).toList();
  }

  // Mettre à jour les statistiques
  void _updateStats() {
    totalSalaries.value = employees
        .where((e) => e.status == EmployeeStatus.active)
        .fold(0, (sum, e) => sum + e.salary);
    
    activeEmployees.value = employees
        .where((e) => e.status == EmployeeStatus.active)
        .length;
    
    inactiveEmployees.value = employees
        .where((e) => e.status == EmployeeStatus.inactive)
        .length;
  }

  // Mettre à jour la recherche
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  // Mettre à jour la position sélectionnée
  void updateSelectedPosition(String? position) {
    if (position != null) {
      selectedPosition.value = position;
    }
  }

  // Mettre à jour le statut sélectionné
  void updateSelectedStatus(String? status) {
    if (status != null) {
      selectedStatus.value = status;
    }
  }

  // Obtenir les tâches d'un employé
  List<EmployeeTaskModel> getEmployeeTasks(String employeeId) {
    print('Getting tasks for employee: $employeeId');
    print('Available tasks: ${tasks.length}');
    print('All tasks: ${tasks.map((t) => {'id': t.id, 'employee_id': t.employeeId}).toList()}');
    
    final employeeTasks = tasks.where((task) {
      final matches = task.employeeId == employeeId;
      print('Checking task ${task.id}: employeeId=${task.employeeId}, matches=$matches');
      return matches;
    }).toList();
    
    print('Found tasks: ${employeeTasks.length}');
    return employeeTasks;
  }

  // Ajouter une nouvelle tâche
  Future<void> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    required String employeeId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final task = EmployeeTaskModel(
        id: _uuid.v4(),
        title: title,
        description: description,
        dueDate: dueDate,
        status: TaskStatus.pending,
        priority: priority,
        employeeId: employeeId,
        completedAt: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      print('Adding task: ${task.toJson()}');
      
      await _supabase
          .from('employee_tasks')
          .insert(task.toJson());
      
      await fetchTasks();
      Get.back();
      showSuccessSnackbar('Succès', 'Tâche ajoutée avec succès');
      
    } catch (e) {
      print('Error adding task: $e');
      error.value = 'Erreur lors de l\'ajout de la tâche: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible d\'ajouter la tâche');
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour une tâche
  Future<void> updateTask(EmployeeTaskModel task) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('Updating task: ${task.toJson()}');
      
      await _supabase
          .from('employee_tasks')
          .update(task.toJson())
          .eq('id', task.id);
      
      await fetchTasks();
      Get.back();
      showSuccessSnackbar('Succès', 'Tâche mise à jour avec succès');
      
    } catch (e) {
      print('Error updating task: $e');
      error.value = 'Erreur lors de la mise à jour de la tâche: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de mettre à jour la tâche');
    } finally {
      isLoading.value = false;
    }
  }

  // Marquer une tâche comme terminée
  Future<void> completeTask(String taskId) async {
    try {
      final task = tasks.firstWhere((t) => t.id == taskId);
      final updatedTask = EmployeeTaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        status: TaskStatus.completed,
        priority: task.priority,
        employeeId: task.employeeId,
        completedAt: DateTime.now(),
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await updateTask(updatedTask);
      
    } catch (e) {
      print('Error completing task: $e');
      error.value = 'Erreur lors de la complétion de la tâche: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de marquer la tâche comme terminée');
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _supabase
          .from('employee_tasks')
          .delete()
          .eq('id', id);
      
      await fetchTasks();
      showSuccessSnackbar('Succès', 'Tâche supprimée avec succès');
      
    } catch (e) {
      print('Error deleting task: $e');
      error.value = 'Erreur lors de la suppression de la tâche: ${e.toString()}';
      showErrorSnackbar('Erreur', 'Impossible de supprimer la tâche');
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer tous les employés
  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final response = await _supabase
          .from('employees')
          .select()
          .order('full_name');

      return (response as List).map((json) => EmployeeModel.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des employés: $e');
      return [];
    }
  }

  // Récupérer les données de salaire pour une période donnée
  Future<Map<String, dynamic>> getSalaryData(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabase
          .from('salary_transactions')
          .select('amount, type, date, employees!inner(full_name)')
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      double totalSalaries = 0;
      for (final transaction in response) {
        if (transaction['type'] == 'salary') {
          totalSalaries += transaction['amount'];
        }
      }

      return {
        'total_salaries': totalSalaries,
        'transactions': response,
      };
    } catch (e) {
      print('Erreur lors de la récupération des données de salaire: $e');
      rethrow;
    }
  }

  // Récupérer les données de performance pour une période donnée
  Future<Map<String, dynamic>> getPerformanceData(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabase
          .from('employee_performances')
          .select('score, date, comments, employees!inner(id, full_name)')
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      Map<String, Map<String, dynamic>> performanceByEmployee = {};
      
      for (final performance in response) {
        final employeeId = performance['employees']['id'];
        final employeeName = performance['employees']['full_name'];
        
        if (!performanceByEmployee.containsKey(employeeId)) {
          performanceByEmployee[employeeId] = {
            'employee_name': employeeName,
            'scores': <int>[],
            'average_score': 0.0,
          };
        }
        
        performanceByEmployee[employeeId]!['scores'].add(performance['score']);
      }

      // Calculer les moyennes
      performanceByEmployee.forEach((employeeId, data) {
        final scores = data['scores'] as List<int>;
        if (scores.isNotEmpty) {
          data['average_score'] = scores.reduce((a, b) => a + b) / scores.length;
        }
      });

      return performanceByEmployee;
    } catch (e) {
      print('Erreur lors de la récupération des données de performance: $e');
      rethrow;
    }
  }
} 