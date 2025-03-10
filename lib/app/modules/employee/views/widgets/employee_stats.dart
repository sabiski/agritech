import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/employee_controller.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class EmployeeStats extends GetView<EmployeeController> {
  const EmployeeStats({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 768;
        final cardWidth = isDesktop
            ? (constraints.maxWidth - 48) / 3
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // Total des salaires
            SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Total des salaires',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        currencyFormat.format(controller.totalSalaries.value),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      const SizedBox(height: 4),
                      const Text(
                        'par mois',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Employés actifs
            SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Employés actifs',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        '${controller.activeEmployees.value}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        'sur ${controller.employees.length} employés',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),

            // Employés inactifs
            SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_off,
                            color: Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Employés inactifs',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        '${controller.inactiveEmployees.value}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        'sur ${controller.employees.length} employés',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 