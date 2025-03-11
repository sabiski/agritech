import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/salary_service.dart';
import '../../services/employee_analytics_service.dart';
import '../../../../data/models/salary_transaction_model.dart';
import 'package:intl/intl.dart';

class SalaryHistoryWidget extends StatelessWidget {
  final String employeeId;
  final String employeeName;
  
  const SalaryHistoryWidget({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  Widget build(BuildContext context) {
    final salaryService = Get.find<SalaryService>();
    final analyticsService = Get.find<EmployeeAnalyticsService>();
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: 'FCFA ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec les statistiques de performance
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance de $employeeName',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPerformanceStats(analyticsService, theme),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Historique des transactions salariales
        Text(
          'Historique des salaires',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final transactions = salaryService.salaryHistory;
          
          if (transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Aucune transaction salariale trouvée',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
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
              return _buildTransactionItem(
                transaction,
                theme,
                currencyFormat,
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildPerformanceStats(
    EmployeeAnalyticsService analyticsService,
    ThemeData theme,
  ) {
    final stats = analyticsService.getEmployeePerformanceStats(employeeId);
    final onTimeRate = (stats['on_time_completion_rate'] as double) * 100;
    
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          theme,
          icon: Icons.task_alt,
          label: 'Tâches totales',
          value: '${stats['total_tasks']}',
        ),
        _buildStatCard(
          theme,
          icon: Icons.check_circle_outline,
          label: 'Complétées à temps',
          value: '${stats['completed_on_time']}',
          color: Colors.green,
        ),
        _buildStatCard(
          theme,
          icon: Icons.warning_amber_rounded,
          label: 'En retard',
          value: '${stats['overdue_tasks']}',
          color: Colors.orange,
        ),
        _buildStatCard(
          theme,
          icon: Icons.percent,
          label: 'Taux de réussite',
          value: '${onTimeRate.toStringAsFixed(1)}%',
          color: _getPerformanceColor(onTimeRate),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? theme.colorScheme.primary,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    SalaryTransactionModel transaction,
    ThemeData theme,
    NumberFormat currencyFormat,
  ) {
    final baseAmount = transaction.amount - (transaction.bonus ?? 0.0);
    final bonusAmount = transaction.bonus ?? 0.0;

    return ListTile(
      title: Row(
        children: [
          Text(
            'Salaire ${transaction.period}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(transaction.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(transaction.status),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getStatusColor(transaction.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildAmountInfo(
                  theme,
                  label: 'Base',
                  amount: baseAmount,
                  currencyFormat: currencyFormat,
                ),
                const SizedBox(width: 16),
                _buildAmountInfo(
                  theme,
                  label: 'Bonus',
                  amount: bonusAmount,
                  currencyFormat: currencyFormat,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildAmountInfo(
                  theme,
                  label: 'Total',
                  amount: transaction.amount,
                  currencyFormat: currencyFormat,
                  isBold: true,
                ),
              ],
            ),
          ),
          if (transaction.bonusReason != null) ...[
            const SizedBox(height: 8),
            Text(
              'Raison du bonus: ${transaction.bonusReason}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
      trailing: Text(
        DateFormat('dd/MM/yyyy').format(transaction.paymentDate),
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  Widget _buildAmountInfo(
    ThemeData theme, {
    required String label,
    required double amount,
    required NumberFormat currencyFormat,
    Color? color,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        Text(
          currencyFormat.format(amount),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }

  Color _getPerformanceColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 70) return Colors.orange;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payé';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }
} 