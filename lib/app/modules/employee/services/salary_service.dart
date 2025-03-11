import 'package:get/get.dart';
import '../../../data/models/salary_transaction_model.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/transaction_model.dart';
import '../services/employee_analytics_service.dart';
import '../services/salary_settings_service.dart';
import '../controllers/employee_controller.dart';
import '../../finance/controllers/finance_controller.dart';
import '../../../services/auth_service.dart';
import 'package:uuid/uuid.dart';

class SalaryService extends GetxService {
  final EmployeeController _employeeController = Get.find<EmployeeController>();
  final FinanceController _financeController = Get.find<FinanceController>();
  final EmployeeAnalyticsService _analyticsService = Get.find<EmployeeAnalyticsService>();
  final SalarySettingsService _settingsService = Get.find<SalarySettingsService>();
  final _authService = Get.find<AuthService>();
  
  // Observable pour l'historique des salaires
  final RxList<SalaryTransactionModel> salaryHistory = <SalaryTransactionModel>[].obs;
  
  // Observable pour le budget salarial
  final Rx<double> salaryBudget = 0.0.obs;
  final Rx<double> totalSalaries = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSalaryBudget();
    _calculateTotalSalaries();
  }

  // Charger le budget salarial depuis les transactions
  Future<void> _loadSalaryBudget() async {
    try {
      final transactions = await _financeController.getTransactionsByCategory(
        category: 'Salaires',
        period: null,
      );
      
      // Trouver la transaction de budget la plus récente
      final budgetTransaction = transactions.lastWhere(
        (t) => t.metadata == null || (t.metadata as Map<String, dynamic>)['type'] != 'salary_payment',
        orElse: () => throw Exception('Aucun budget salarial défini'),
      );
      
      salaryBudget.value = budgetTransaction.amount ?? 0.0;
      print('Budget salarial chargé: ${salaryBudget.value}');
    } catch (e) {
      print('Erreur lors du chargement du budget salarial: $e');
      salaryBudget.value = 0.0;
    }
  }

  // Calculer la somme des salaires actuels
  void _calculateTotalSalaries() {
    final total = _employeeController.employees
        .where((e) => e.status == EmployeeStatus.active)
        .fold<double>(0.0, (sum, employee) => sum + employee.salary);
    
    totalSalaries.value = total;
    print('Total des salaires: ${totalSalaries.value}');
  }

  // Vérifier si l'ajout d'un nouveau salaire dépasse le budget
  bool canAddSalary(double newSalary) {
    final projectedTotal = totalSalaries.value + newSalary;
    return projectedTotal <= salaryBudget.value;
  }

  // Obtenir le montant restant du budget
  double getRemainingBudget() {
    return salaryBudget.value - totalSalaries.value;
  }

  // Calculer le bonus basé sur la performance
  double calculatePerformanceBonus(String employeeId, double baseSalary) {
    final stats = _analyticsService.getEmployeePerformanceStats(employeeId);
    final settings = _settingsService.settings.value;
    
    double bonusPercentage = 0.0;
    
    // Bonus pour le taux de complétion dans les délais
    if (stats['on_time_completion_rate'] > settings.excellentPerformanceRate) {
      bonusPercentage += settings.onTimeCompletionBonus;
    } else if (stats['on_time_completion_rate'] > settings.goodPerformanceRate) {
      bonusPercentage += settings.onTimeCompletionBonus / 2;
    }
    
    // Malus pour les tâches en retard
    if (stats['overdue_tasks'] > 0) {
      bonusPercentage -= settings.overdueTaskPenalty * stats['overdue_tasks'];
    }
    
    // Bonus pour productivité élevée
    if (stats['total_tasks'] >= settings.productivityTaskThreshold && 
        stats['completed_on_time'] >= settings.productivityCompletionThreshold) {
      bonusPercentage += settings.highProductivityBonus;
    }
    
    // S'assurer que le bonus ne devient pas négatif et ne dépasse pas le maximum
    bonusPercentage = bonusPercentage.clamp(0.0, settings.maxTotalBonus);
    
    return baseSalary * bonusPercentage;
  }

  // Créer une transaction salariale
  Future<void> createSalaryTransaction(
    String employeeId,
    double baseSalary,
  ) async {
    try {
      print('Creating salary transaction for employee: $employeeId');
      final now = DateTime.now();
      final period = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final bonusAmount = calculatePerformanceBonus(employeeId, baseSalary);
      final totalAmount = baseSalary + bonusAmount;

      final stats = _analyticsService.getEmployeePerformanceStats(employeeId);
      
      // Récupérer les informations de l'employé
      final employee = _employeeController.employees.firstWhere(
        (e) => e.id == employeeId,
        orElse: () => throw Exception('Employee not found'),
      );
      
      final metadata = {
        'type': 'salary_payment',
        'employee_id': employeeId,
        'employee_name': employee.fullName,
        'position': employee.position,
        'base_amount': baseSalary,
        'bonus_amount': bonusAmount,
        'period': period,
        'performance_metrics': stats
      };
      
      print('Creating transaction with metadata: $metadata');
      
      // Créer la transaction financière avec les métadonnées de salaire
      await _financeController.createTransaction(
        amount: totalAmount,
        type: 'expense',
        category: 'Salaires',
        description: 'Salaire ${employee.fullName} - $period',
        farmerId: _authService.currentUser?.id ?? '',
        metadata: metadata,
      );

      print('Transaction created successfully');
      
      // Mettre à jour l'historique
      await fetchSalaryHistory(employeeId);
    } catch (e) {
      print('Error creating salary transaction: $e');
      rethrow;
    }
  }

  // Obtenir l'historique des transactions salariales d'un employé
  Future<List<SalaryTransactionModel>> getEmployeeSalaryHistory(String? employeeId) async {
    try {
      print('Fetching salary history for employee: $employeeId');
      
      final transactions = await _financeController.getTransactionsByCategory(
        category: 'Salaires',
        period: null,
      );
      
      print('Found ${transactions.length} transactions in Salaires category');
      print('Transactions: ${transactions.map((t) => {'id': t.id, 'type': t.type, 'metadata': t.metadata}).toList()}');
      
      // Filtrer les transactions
      final filteredTransactions = transactions.where((transaction) {
        // Ne garder que les dépenses
        if (transaction.type != 'expense') {
          print('Skipping non-expense transaction: ${transaction.id}');
          return false;
        }
        
        // Vérifier les métadonnées
        final metadata = transaction.metadata as Map<String, dynamic>?;
        if (metadata == null) {
          print('Skipping transaction without metadata: ${transaction.id}');
          return false;
        }
        
        // Si un employé spécifique est demandé, filtrer par son ID
        if (employeeId != null) {
          final isMatch = metadata['type'] == 'salary_payment' && 
                         metadata['employee_id'] == employeeId;
          print('Transaction ${transaction.id} match for employee $employeeId: $isMatch');
          return isMatch;
        }
        
        // Sinon retourner toutes les transactions de type salary_payment
        return metadata['type'] == 'salary_payment';
      }).map((transaction) {
        final metadata = transaction.metadata as Map<String, dynamic>;
        
        // Récupérer les informations de l'employé
        EmployeeModel? employee;
        try {
          employee = _employeeController.employees.firstWhere(
            (e) => e.id == metadata['employee_id'],
          );
        } catch (e) {
          print('Employee not found for transaction: ${transaction.id}');
        }
        
        return SalaryTransactionModel(
          id: transaction.id,
          employeeId: metadata['employee_id'],
          employeeName: employee?.fullName ?? metadata['employee_name'] ?? 'Employé inconnu',
          baseAmount: (metadata['base_amount'] as num).toDouble(),
          bonusAmount: (metadata['bonus_amount'] as num).toDouble(),
          totalAmount: transaction.amount ?? 0.0,
          paymentDate: transaction.date ?? DateTime.now(),
          period: metadata['period'],
          status: 'completed',
          performanceMetrics: metadata['performance_metrics'],
          createdAt: transaction.createdAt ?? DateTime.now(),
          updatedAt: transaction.updatedAt ?? DateTime.now(),
        );
      }).toList();
      
      print('Found ${filteredTransactions.length} salary transactions');
      
      salaryHistory.value = filteredTransactions;
      return filteredTransactions;
    } catch (e) {
      print('Error fetching salary history: $e');
      return [];
    }
  }

  // Mettre à jour l'historique des salaires
  Future<void> fetchSalaryHistory(String? employeeId) async {
    await getEmployeeSalaryHistory(employeeId);
  }

  // Calculer le coût total des salaires pour une période donnée
  Future<double> calculateTotalSalaryExpenses(String period) async {
    final transactions = await _financeController.getTransactionsByCategory(
      category: 'Salaires',
      period: period,
    );
    
    // Ne compter que les dépenses de type salary_payment
    return transactions
        .where((t) => t.type == 'expense' && 
                     (t.metadata as Map<String, dynamic>?)?['type'] == 'salary_payment')
        .fold<double>(0.0, (sum, transaction) => sum + (transaction.amount ?? 0.0));
  }

  // Obtenir les informations de salaire d'un employé
  Map<String, dynamic> getEmployeeSalaryInfo(String employeeId) {
    final employee = _employeeController.employees.firstWhere(
      (e) => e.id == employeeId,
      orElse: () => throw Exception('Employé non trouvé'),
    );

    final baseSalary = employee.salary;
    final bonusAmount = calculatePerformanceBonus(employeeId, baseSalary);
    final totalSalary = baseSalary + bonusAmount;

    return {
      'employee': employee,
      'base_salary': baseSalary,
      'bonus_amount': bonusAmount,
      'total_salary': totalSalary,
      'performance_metrics': _analyticsService.getEmployeePerformanceStats(employeeId),
    };
  }
} 