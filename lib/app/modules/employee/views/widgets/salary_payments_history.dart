import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/salary_service.dart';
import 'package:intl/intl.dart';

class SalaryPaymentsHistory extends StatelessWidget {
  final String employeeId;
  final String employeeName;

  const SalaryPaymentsHistory({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  Widget build(BuildContext context) {
    final salaryService = Get.find<SalaryService>();
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: 'FCFA ',
      decimalDigits: 0,
    );

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 800 : MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Historique des paiements - $employeeName',
                    style: theme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final transactions = salaryService.salaryHistory;

                if (transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun paiement enregistré',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final isMobile = MediaQuery.of(context).size.width < 600;

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(transaction.status).withOpacity(0.1),
                              child: Icon(
                                _getStatusIcon(transaction.status),
                                color: _getStatusColor(transaction.status),
                              ),
                            ),
                            title: Text(
                              'Salaire ${transaction.period}',
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy').format(transaction.paymentDate),
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Container(
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
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildAmountInfo(
                                      theme,
                                      label: 'Base',
                                      amount: transaction.amount - (transaction.bonus ?? 0.0),
                                      currencyFormat: currencyFormat,
                                    ),
                                    _buildAmountInfo(
                                      theme,
                                      label: 'Bonus',
                                      amount: transaction.bonus ?? 0.0,
                                      currencyFormat: currencyFormat,
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildAmountInfo(
                                      theme,
                                      label: 'Total',
                                      amount: transaction.amount,
                                      currencyFormat: currencyFormat,
                                      isBold: true,
                                    ),
                                    if (transaction.bonusReason != null)
                                      Text(
                                        'Raison: ${transaction.bonusReason}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    // Vue desktop
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(transaction.status).withOpacity(0.1),
                        child: Icon(
                          _getStatusIcon(transaction.status),
                          color: _getStatusColor(transaction.status),
                        ),
                      ),
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
                          Row(
                            children: [
                              _buildAmountInfo(
                                theme,
                                label: 'Base',
                                amount: transaction.amount - (transaction.bonus ?? 0.0),
                                currencyFormat: currencyFormat,
                              ),
                              const SizedBox(width: 24),
                              _buildAmountInfo(
                                theme,
                                label: 'Bonus',
                                amount: transaction.bonus ?? 0.0,
                                currencyFormat: currencyFormat,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 24),
                              _buildAmountInfo(
                                theme,
                                label: 'Total',
                                amount: transaction.amount,
                                currencyFormat: currencyFormat,
                                isBold: true,
                              ),
                            ],
                          ),
                          if (transaction.bonusReason != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Raison: ${transaction.bonusReason}',
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
                  },
                );
              }),
            ),
          ],
        ),
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
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