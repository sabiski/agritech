import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/employee_controller.dart';
import '../../../../core/theme/app_theme.dart';
import 'employee_item.dart';

class EmployeeList extends GetView<EmployeeController> {
  const EmployeeList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.filteredEmployees.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun employé trouvé',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des employés en cliquant sur le bouton +',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 768;
                final crossAxisCount = isDesktop ? 2 : 1;
                final itemWidth = (constraints.maxWidth - (16 * (crossAxisCount - 1))) / crossAxisCount;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 160,
                  ),
                  itemCount: controller.filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = controller.filteredEmployees[index];
                    return EmployeeItem(
                      employee: employee,
                      width: itemWidth,
                    );
                  },
                );
              },
            ),
    );
  }
} 