import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/finance_controller.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class FinanceStats extends GetView<FinanceController> {
  const FinanceStats({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryGreen.withOpacity(0.2),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Layout mobile
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildStatCard(
                        icon: Icons.arrow_upward,
                        title: 'Revenus',
                        value: currencyFormat.format(controller.totalIncome.value),
                        color: Colors.green,
                        isCompact: false,
                      )),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => _buildStatCard(
                        icon: Icons.arrow_downward,
                        title: 'Dépenses',
                        value: currencyFormat.format(controller.totalExpense.value),
                        color: Colors.red,
                        isCompact: false,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => _buildStatCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Solde',
                  value: currencyFormat.format(controller.balance.value),
                  color: controller.balance.value >= 0 ? Colors.blue : Colors.orange,
                  isCompact: false,
                )),
              ],
            );
          }
          
          // Layout desktop
          return Row(
            children: [
              Expanded(
                child: Obx(() => _buildStatCard(
                  icon: Icons.arrow_upward,
                  title: 'Revenus',
                  value: currencyFormat.format(controller.totalIncome.value),
                  color: Colors.green,
                  isCompact: true,
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => _buildStatCard(
                  icon: Icons.arrow_downward,
                  title: 'Dépenses',
                  value: currencyFormat.format(controller.totalExpense.value),
                  color: Colors.red,
                  isCompact: true,
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => _buildStatCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Solde',
                  value: currencyFormat.format(controller.balance.value),
                  color: controller.balance.value >= 0 ? Colors.blue : Colors.orange,
                  isCompact: true,
                )),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isCompact,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 20 : 16,
          vertical: isCompact ? 16 : 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isCompact ? 20 : 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: isCompact ? 14 : 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 8 : 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: isCompact ? 22 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 