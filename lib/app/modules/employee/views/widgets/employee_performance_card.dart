import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/employee_analytics_service.dart';
import '../../../../core/theme/app_theme.dart';

class EmployeePerformanceCard extends StatelessWidget {
  final String employeeId;
  final EmployeeAnalyticsService _analyticsService = Get.find<EmployeeAnalyticsService>();

  EmployeePerformanceCard({
    super.key,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _analyticsService.getEmployeePerformanceStats(employeeId);
    final notifications = _analyticsService.getEmployeeNotifications(employeeId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (notifications.isNotEmpty) ...[
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: Icon(
                    _getNotificationIcon(notification['icon'] as String),
                    color: _getNotificationColor(notification['type'] as String),
                  ),
                  title: Text(notification['title'] as String),
                  subtitle: Text(notification['message'] as String),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Tâches totales',
                stats['total_tasks'].toString(),
                Icons.assignment,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Complétées à temps',
                stats['completed_on_time'].toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'En retard',
                stats['overdue_tasks'].toString(),
                Icons.warning,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Taux de réussite',
                '${(stats['on_time_completion_rate'] * 100).toStringAsFixed(0)}%',
                Icons.trending_up,
                AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String icon) {
    switch (icon) {
      case 'warning':
        return Icons.warning;
      case 'person_off':
        return Icons.person_off;
      case 'star':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
} 