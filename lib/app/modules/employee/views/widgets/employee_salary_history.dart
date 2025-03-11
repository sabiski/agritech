import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/salary_service.dart';
import '../../../../data/models/salary_transaction_model.dart';
import 'package:intl/intl.dart';

class EmployeeSalaryHistory extends StatelessWidget {
  final String employeeId;
  final SalaryService _salaryService = Get.find<SalaryService>();
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  EmployeeSalaryHistory({
    super.key,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des salaires',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<SalaryTransactionModel>>(
          future: _salaryService.getEmployeeSalaryHistory(employeeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur lors du chargement de l\'historique',
                  style: TextStyle(color: Colors.red[700]),
                ),
              );
            }

            final transactions = snapshot.data ?? [];

            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune transaction salariale',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildSalaryItem(context, transaction);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSalaryItem(BuildContext context, SalaryTransactionModel transaction) {
    final theme = Theme.of(context);
    final hasBonus = transaction.bonusAmount > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Période : ${transaction.period}',
                  style: theme.textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(transaction.status),
                    style: TextStyle(
                      color: _getStatusColor(transaction.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salaire de base',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      currencyFormat.format(transaction.baseAmount),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                if (hasBonus)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Bonus performance',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '+ ${currencyFormat.format(transaction.bonusAmount)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  currencyFormat.format(transaction.totalAmount),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (transaction.performanceMetrics != null) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Détails de performance'),
                children: [
                  _buildPerformanceDetails(
                    context,
                    transaction.performanceMetrics!,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceDetails(
    BuildContext context,
    Map<String, dynamic> metrics,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricRow(
            context,
            'Tâches totales',
            metrics['total_tasks'].toString(),
          ),
          _buildMetricRow(
            context,
            'Complétées à temps',
            metrics['completed_on_time'].toString(),
          ),
          _buildMetricRow(
            context,
            'Tâches en retard',
            metrics['overdue_tasks'].toString(),
          ),
          _buildMetricRow(
            context,
            'Taux de réussite',
            '${(metrics['on_time_completion_rate'] * 100).toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'paid':
        return 'Payé';
      case 'cancelled':
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }
} 