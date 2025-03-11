import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_controller.dart';
import '../../../data/models/report_model.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobileLayout(context);
          }
          return _buildDesktopLayout(context);
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // App bar for mobile
        AppBar(
          title: const Text('Rapports'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showNewReportDialog(context),
            ),
          ],
        ),
        // Filters section
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtres',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildTypeFilter(),
              const SizedBox(height: 16),
              _buildDateRangeFilter(context),
            ],
          ),
        ),
        // Reports list
        Expanded(
          child: _buildReportList(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Sidebar for filters
        Container(
          width: 300,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rapports',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                _buildNewReportButton(context),
                const SizedBox(height: 32),
                Text(
                  'Filtres',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildTypeFilter(),
                const SizedBox(height: 16),
                _buildDateRangeFilter(context),
              ],
            ),
          ),
        ),
        // Reports list
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historique des rapports',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildReportList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewReportButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showNewReportDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.add),
      label: const Text('Nouveau rapport'),
    );
  }

  Widget _buildTypeFilter() {
    return Obx(() => DropdownButtonFormField<ReportType>(
      value: controller.selectedType.value,
      decoration: const InputDecoration(
        labelText: 'Type de rapport',
        border: OutlineInputBorder(),
      ),
      items: ReportType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getReportTypeName(type)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          controller.selectedType.value = value;
        }
      },
    ));
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Période'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(() => TextButton.icon(
                onPressed: () => _selectDateRange(context),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  '${DateFormat('dd/MM/yyyy').format(controller.startDate.value)} - '
                  '${DateFormat('dd/MM/yyyy').format(controller.endDate.value)}',
                ),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(controller.error.value),
            ],
          ),
        );
      }

      if (controller.reports.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Aucun rapport disponible'),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.reports.length,
        itemBuilder: (context, index) {
          final report = controller.reports[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(report.title),
              subtitle: Text(
                '${report.type.toString().split('.').last} - ${DateFormat('dd/MM/yyyy').format(report.startDate)} à ${DateFormat('dd/MM/yyyy').format(report.endDate)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () => controller.exportReport(report),
                    tooltip: 'Exporter',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => controller.deleteReport(report.id),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
              onTap: () => controller.showReportDetails(report),
            ),
          );
        },
      );
    });
  }

  Widget _buildReportCard(ReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getReportTypeIcon(report.type),
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildExportMenu(report),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    'Période',
                    '${DateFormat('dd/MM/yyyy').format(report.startDate)} - '
                    '${DateFormat('dd/MM/yyyy').format(report.endDate)}',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    'Type',
                    _getReportTypeName(report.type),
                  ),
                ],
              ),
              if (report.exportedAt != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      report.exportFormat == ReportFormat.pdf
                          ? Icons.picture_as_pdf
                          : Icons.table_chart,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Exporté le ${DateFormat('dd/MM/yyyy HH:mm').format(report.exportedAt!)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportMenu(ReportModel report) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf),
              SizedBox(width: 8),
              Text('Exporter en PDF'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'excel',
          child: Row(
            children: [
              Icon(Icons.table_chart),
              SizedBox(width: 8),
              Text('Exporter en Excel'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'pdf':
            await controller.exportToPdf(report);
            break;
          case 'excel':
            await controller.exportToExcel(report);
            break;
          case 'delete':
            _showDeleteConfirmation(report);
            break;
        }
      },
    );
  }

  void _showNewReportDialog(BuildContext context) {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final selectedType = controller.selectedType;
    final selectedChartType = controller.selectedChartType;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouveau rapport',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre du rapport',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le titre est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<ReportType>(
                  value: selectedType.value,
                  decoration: const InputDecoration(
                    labelText: 'Type de rapport',
                    border: OutlineInputBorder(),
                  ),
                  items: ReportType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getReportTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedType.value = value;
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Le type de rapport est requis';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<ChartType>(
                  value: selectedChartType.value,
                  decoration: const InputDecoration(
                    labelText: 'Type de graphique',
                    border: OutlineInputBorder(),
                  ),
                  items: ChartType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getChartTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedChartType.value = value;
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Le type de graphique est requis';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final report = await controller.generateReport(
                            title: titleController.text,
                            type: selectedType.value,
                            startDate: controller.startDate.value,
                            endDate: controller.endDate.value,
                            chartType: selectedChartType.value,
                          );

                          if (report != null) {
                            Get.back();
                            Get.snackbar(
                              'Succès',
                              'Le rapport a été généré avec succès',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Générer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDetails(ReportModel report) {
    // TODO: Implémenter l'affichage détaillé du rapport
  }

  void _showDeleteConfirmation(ReportModel report) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce rapport ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: Supprimer le rapport
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: controller.startDate.value,
      end: controller.endDate.value,
    );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
    );

    if (newDateRange != null) {
      controller.startDate.value = newDateRange.start;
      controller.endDate.value = newDateRange.end;
    }
  }

  String _getReportTypeName(ReportType type) {
    switch (type) {
      case ReportType.finance:
        return 'Rapport financier';
      case ReportType.employee:
        return 'Rapport des employés';
      case ReportType.stock:
        return 'Rapport des stocks';
      case ReportType.crop:
        return 'Rapport des cultures';
    }
  }

  String _getChartTypeName(ChartType type) {
    switch (type) {
      case ChartType.bar:
        return 'Graphique à barres';
      case ChartType.line:
        return 'Graphique linéaire';
      case ChartType.pie:
        return 'Graphique circulaire';
      case ChartType.scatter:
        return 'Nuage de points';
    }
  }

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.finance:
        return Icons.attach_money;
      case ReportType.employee:
        return Icons.people;
      case ReportType.stock:
        return Icons.inventory;
      case ReportType.crop:
        return Icons.grass;
    }
  }
} 