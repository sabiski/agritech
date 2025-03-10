import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_controller.dart';
import '../../../data/models/employee_model.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/employee_tasks.dart';
import 'package:intl/intl.dart';

class EmployeeDetailView extends GetView<EmployeeController> {
  final EmployeeModel employee;

  const EmployeeDetailView({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
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
            
            // Tâches de l'employé
            EmployeeTasks(employeeId: employee.id),
          ],
        ),
      ),
    );
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