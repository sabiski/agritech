import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/stock_controller.dart';
import '../../../../core/theme/app_theme.dart';

class StockStats extends GetView<StockController> {
  const StockStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryGreen.withOpacity(0.2),
          ),
        ),
      ),
      child: Obx(() {
        final expiredCount = controller.expiredStocks.length;
        final nearExpirationCount = controller.nearExpirationStocks.length;
        final lowStockCount = controller.lowStocks.length;
        final totalCount = controller.stocks.length;

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Layout mobile
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.inventory,
                          title: 'Total',
                          value: totalCount.toString(),
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.warning,
                          title: 'Stock bas',
                          value: lowStockCount.toString(),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.access_time,
                          title: 'Bientôt périmés',
                          value: nearExpirationCount.toString(),
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.error_outline,
                          title: 'Périmés',
                          value: expiredCount.toString(),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            
            // Layout desktop
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.inventory,
                    title: 'Total des produits',
                    value: totalCount.toString(),
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.warning,
                    title: 'Stock bas',
                    value: lowStockCount.toString(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.access_time,
                    title: 'Bientôt périmés',
                    value: nearExpirationCount.toString(),
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.error_outline,
                    title: 'Périmés',
                    value: expiredCount.toString(),
                    color: Colors.red,
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 