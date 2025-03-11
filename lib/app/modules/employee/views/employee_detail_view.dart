import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_controller.dart';
import '../../../data/models/employee_model.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/employee_tasks.dart';
import 'widgets/salary_history_widget.dart';
import '../services/salary_service.dart';
import 'package:intl/intl.dart';
import 'widgets/salary_payments_history.dart';

class EmployeeDetailView extends GetView<EmployeeController> {
  final EmployeeModel employee;

  const EmployeeDetailView({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    final salaryService = Get.find<SalaryService>();
    
    // Charger l'historique des salaires au chargement de la vue
    print('Chargement de l\'historique pour l\'employé: ${employee.id}');
    salaryService.fetchSalaryHistory(employee.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(employee.fullName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations de l'employé
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      'Poste',
                      employee.position,
                      Icons.work,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      'Salaire',
                      '${NumberFormat.currency(symbol: 'FCFA', decimalDigits: 0).format(employee.salary)}',
                      Icons.attach_money,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      'Téléphone',
                      employee.phoneNumber,
                      Icons.phone,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      'Email',
                      employee.email,
                      Icons.email,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      'Date d\'embauche',
                      DateFormat('dd/MM/yyyy').format(employee.startDate),
                      Icons.calendar_today,
                    ),
                    if (employee.address != null && employee.address!.isNotEmpty) ...[
                      const Divider(),
                      _buildInfoRow(
                        context,
                        'Adresse',
                        employee.address!,
                        Icons.location_on,
                      ),
                    ],
                    if (employee.notes != null && employee.notes!.isNotEmpty) ...[
                      const Divider(),
                      _buildInfoRow(
                        context,
                        'Notes',
                        employee.notes!,
                        Icons.note,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Historique des salaires et performances
            SalaryHistoryWidget(
              employeeId: employee.id,
              employeeName: employee.fullName,
            ),
            const SizedBox(height: 24),
            
            // Tâches de l'employé
            EmployeeTasks(employeeId: employee.id),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (MediaQuery.of(context).size.width < 600) {
              // Vue mobile : menu flottant avec options
              return FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.history, color: Colors.blue),
                          title: const Text('Historique des paiements'),
                          onTap: () {
                            Navigator.pop(context);
                            Get.dialog(
                              SalaryPaymentsHistory(
                                employeeId: employee.id,
                                employeeName: employee.fullName,
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.payments, color: AppTheme.primaryGreen),
                          title: const Text('Payer le salaire'),
                          onTap: () {
                            Navigator.pop(context);
                            _showPaymentDialog(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.more_vert),
              );
            }
            // Vue desktop : boutons côte à côte
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'history',
                  onPressed: () {
                    Get.dialog(
                      SalaryPaymentsHistory(
                        employeeId: employee.id,
                        employeeName: employee.fullName,
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Historique des paiements'),
                  backgroundColor: Colors.blue,
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'pay',
                  onPressed: () => _showPaymentDialog(context),
                  icon: const Icon(Icons.payments),
                  label: const Text('Payer le salaire'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showPaymentDialog(BuildContext context) async {
    final now = DateTime.now();
    final period = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final salaryService = Get.find<SalaryService>();

    // Vérifier si un paiement existe déjà pour ce mois
    final existingPayment = await salaryService.checkExistingPayment(employee.id, period);
    if (existingPayment) {
      Get.snackbar(
        'Erreur',
        'Le salaire a déjà été payé pour ce mois',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Vérifier si l'employé est actif
    if (employee.status != EmployeeStatus.active) {
      Get.snackbar(
        'Erreur',
        'Impossible de payer un employé inactif',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await salaryService.createSalaryTransaction(
        employee.id,
        employee.salary,
      );
      
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        'Succès',
        'Le salaire a été payé avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        'Erreur',
        'Impossible de créer la transaction: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 