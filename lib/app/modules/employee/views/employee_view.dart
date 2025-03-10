import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_controller.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/employee_stats.dart';
import 'widgets/employee_list.dart';
import 'widgets/employee_form.dart';

class EmployeeView extends GetView<EmployeeController> {
  const EmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Employés'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchEmployees,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statistiques
              const EmployeeStats(),
              const SizedBox(height: 24),

              // Barre de recherche et filtres
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: controller.updateSearch,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un employé...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Filtre par poste
                  Obx(
                    () => DropdownButton<String>(
                      value: controller.selectedPosition.value,
                      items: controller.positions
                          .map((position) => DropdownMenuItem(
                                value: position,
                                child: Text(position),
                              ))
                          .toList(),
                      onChanged: controller.updateSelectedPosition,
                      hint: const Text('Poste'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Filtre par statut
                  Obx(
                    () => DropdownButton<String>(
                      value: controller.selectedStatus.value,
                      items: controller.statuses
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: controller.updateSelectedStatus,
                      hint: const Text('Statut'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // État de chargement ou liste des employés
              Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : const EmployeeList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.dialog(
          Dialog(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(16),
              child: const SingleChildScrollView(
                child: EmployeeForm(),
              ),
            ),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un employé'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
} 