import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/report_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../finance/controllers/finance_controller.dart';
import '../../employee/controllers/employee_controller.dart';
import '../../stock/controllers/stock_controller.dart';
import '../../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _financeController = Get.find<FinanceController>();
  final _employeeController = Get.find<EmployeeController>();
  final _stockController = Get.find<StockController>();

  // État observable
  final RxList<ReportModel> reports = <ReportModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Filtres observables
  final Rx<ReportType> selectedType = ReportType.finance.obs;
  final Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final Rx<ChartType> selectedChartType = ChartType.bar.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  // Charger les rapports existants
  Future<void> loadReports() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await _supabase
          .from('reports')
          .select()
          .order('created_at', ascending: false);
      
      reports.value = (response as List)
          .map((json) => ReportModel.fromJson(json))
          .toList();
      
    } catch (e) {
      print('Erreur lors du chargement des rapports: $e');
      error.value = 'Erreur lors du chargement des rapports: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Générer un nouveau rapport
  Future<ReportModel?> generateReport({
    required String title,
    required ReportType type,
    required DateTime startDate,
    required DateTime endDate,
    required ChartType chartType,
    Map<String, dynamic> filters = const {},
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Récupérer les données selon le type de rapport
      final data = await _getReportData(type, startDate, endDate, filters);

      final report = ReportModel(
        id: const Uuid().v4(),
        title: title,
        type: type,
        startDate: startDate,
        endDate: endDate,
        filters: filters,
        chartType: chartType,
        data: data,
        createdAt: DateTime.now(),
      );

      // Sauvegarder le rapport dans Supabase
      await _supabase
          .from('reports')
          .insert({
            ...report.toJson(),
            'farmer_id': _supabase.auth.currentUser!.id,
          });

      reports.add(report);
      return report;

    } catch (e) {
      print('Erreur lors de la génération du rapport: $e');
      error.value = 'Erreur lors de la génération du rapport: $e';
      Get.snackbar(
        'Erreur',
        'Impossible de générer le rapport: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer les données selon le type de rapport
  Future<Map<String, dynamic>> _getReportData(
    ReportType type,
    DateTime startDate,
    DateTime endDate,
    Map<String, dynamic> filters,
  ) async {
    switch (type) {
      case ReportType.finance:
        return await _getFinanceReportData(startDate, endDate, filters);
      case ReportType.employee:
        return await _getEmployeeReportData(startDate, endDate, filters);
      case ReportType.stock:
        return await _getStockReportData(startDate, endDate, filters);
      case ReportType.crop:
        return await _getCropReportData(startDate, endDate, filters);
      default:
        throw Exception('Type de rapport non supporté');
    }
  }

  // Données pour le rapport financier
  Future<Map<String, dynamic>> _getFinanceReportData(
    DateTime startDate,
    DateTime endDate,
    Map<String, dynamic> filters,
  ) async {
    final transactions = await _financeController.getTransactionsByPeriod(
      startDate: startDate,
      endDate: endDate,
    );

    double totalRevenue = 0;
    double totalExpenses = 0;
    Map<String, double> revenueByCategory = {};
    Map<String, double> expensesByCategory = {};

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalRevenue += transaction.amount;
        revenueByCategory[transaction.category] = 
          (revenueByCategory[transaction.category] ?? 0) + transaction.amount;
      } else {
        totalExpenses += transaction.amount;
        expensesByCategory[transaction.category] = 
          (expensesByCategory[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return {
      'total_revenue': totalRevenue,
      'total_expenses': totalExpenses,
      'net_profit': totalRevenue - totalExpenses,
      'revenue_by_category': revenueByCategory,
      'expenses_by_category': expensesByCategory,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  // Données pour le rapport des employés
  Future<Map<String, dynamic>> _getEmployeeReportData(
    DateTime startDate,
    DateTime endDate,
    Map<String, dynamic> filters,
  ) async {
    final employees = await _employeeController.getEmployees();
    final salaryData = await _employeeController.getSalaryData(startDate, endDate);
    final performanceData = await _employeeController.getPerformanceData(startDate, endDate);

    return {
      'employees': employees.map((e) => e.toJson()).toList(),
      'salary_data': salaryData,
      'performance_data': performanceData,
    };
  }

  // Données pour le rapport des stocks
  Future<Map<String, dynamic>> _getStockReportData(
    DateTime startDate,
    DateTime endDate,
    Map<String, dynamic> filters,
  ) async {
    final stockItems = await _stockController.getStockItems();
    final stockMovements = await _stockController.getStockMovements(startDate, endDate);
    final lowStockItems = stockItems.where((item) => item.quantity <= item.minQuantity).toList();

    return {
      'stock_items': stockItems.map((i) => i.toJson()).toList(),
      'stock_movements': stockMovements.map((m) => m.toJson()).toList(),
      'low_stock_items': lowStockItems.map((i) => i.toJson()).toList(),
    };
  }

  // Données pour le rapport des cultures
  Future<Map<String, dynamic>> _getCropReportData(
    DateTime startDate,
    DateTime endDate,
    Map<String, dynamic> filters,
  ) async {
    // TODO: Implémenter la récupération des données des cultures
    return {};
  }

  // Exporter le rapport en PDF
  Future<String?> exportToPdf(ReportModel report) async {
    try {
      final pdf = pw.Document();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/report_${report.id}.pdf');

      // Ajouter l'en-tête
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                report.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Période: ${DateFormat('dd/MM/yyyy').format(report.startDate)} - ${DateFormat('dd/MM/yyyy').format(report.endDate)}',
              ),
              pw.SizedBox(height: 20),
              _buildPdfContent(report),
            ],
          ),
        ),
      );

      // Sauvegarder le PDF
      await file.writeAsBytes(await pdf.save());

      // Mettre à jour le rapport dans Supabase
      await _supabase
          .from('reports')
          .update({
            'exported_at': DateTime.now().toIso8601String(),
            'export_format': ReportFormat.pdf.toString(),
          })
          .eq('id', report.id);

      return file.path;

    } catch (e) {
      print('Erreur lors de l\'export en PDF: $e');
      error.value = 'Erreur lors de l\'export en PDF: $e';
      return null;
    }
  }

  // Construire le contenu du PDF selon le type de rapport
  pw.Widget _buildPdfContent(ReportModel report) {
    switch (report.type) {
      case ReportType.finance:
        return _buildFinancePdfContent(report.data);
      case ReportType.employee:
        return _buildEmployeePdfContent(report.data);
      case ReportType.stock:
        return _buildStockPdfContent(report.data);
      case ReportType.crop:
        return _buildCropPdfContent(report.data);
      default:
        return pw.Container();
    }
  }

  // Contenu PDF pour le rapport financier
  pw.Widget _buildFinancePdfContent(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Résumé Financier',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Revenus totaux: ${NumberFormat.currency(symbol: 'FCFA').format(data['total_revenue'])}'),
        pw.Text('Dépenses totales: ${NumberFormat.currency(symbol: 'FCFA').format(data['total_expenses'])}'),
        pw.Text('Bénéfice net: ${NumberFormat.currency(symbol: 'FCFA').format(data['net_profit'])}'),
        // TODO: Ajouter des graphiques et plus de détails
      ],
    );
  }

  // Contenu PDF pour le rapport des employés
  pw.Widget _buildEmployeePdfContent(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Rapport des Employés',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Total des salaires: ${NumberFormat.currency(symbol: 'FCFA').format(data['salary_data']['total_salaries'])}'),
        // TODO: Ajouter des graphiques et plus de détails
      ],
    );
  }

  // Contenu PDF pour le rapport des stocks
  pw.Widget _buildStockPdfContent(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Rapport des Stocks',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Articles en stock faible: ${(data['low_stock_items'] as List).length}'),
        // TODO: Ajouter des graphiques et plus de détails
      ],
    );
  }

  // Contenu PDF pour le rapport des cultures
  pw.Widget _buildCropPdfContent(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Rapport des Cultures',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        // TODO: Implémenter le contenu du rapport des cultures
      ],
    );
  }

  // Exporter le rapport en Excel
  Future<String?> exportToExcel(ReportModel report) async {
    try {
      final excel = Excel.createExcel();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/report_${report.id}.xlsx');
      final sheet = excel['Report'];

      // Ajouter l'en-tête
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        ..value = TextCellValue(report.title)
        ..cellStyle = CellStyle(
          bold: true,
          fontSize: 14,
        );

      // Ajouter le contenu selon le type de rapport
      _addExcelContent(sheet, report);

      // Sauvegarder le fichier Excel
      await file.writeAsBytes(excel.encode()!);

      // Mettre à jour le rapport dans Supabase
      await _supabase
          .from('reports')
          .update({
            'exported_at': DateTime.now().toIso8601String(),
            'export_format': ReportFormat.excel.toString(),
          })
          .eq('id', report.id);

      return file.path;

    } catch (e) {
      print('Erreur lors de l\'export en Excel: $e');
      error.value = 'Erreur lors de l\'export en Excel: $e';
      return null;
    }
  }

  // Ajouter le contenu Excel selon le type de rapport
  void _addExcelContent(Sheet sheet, ReportModel report) {
    switch (report.type) {
      case ReportType.finance:
        _addFinanceExcelContent(sheet, report.data);
        break;
      case ReportType.employee:
        _addEmployeeExcelContent(sheet, report.data);
        break;
      case ReportType.stock:
        _addStockExcelContent(sheet, report.data);
        break;
      case ReportType.crop:
        _addCropExcelContent(sheet, report.data);
        break;
    }
  }

  // Contenu Excel pour le rapport financier
  void _addFinanceExcelContent(Sheet sheet, Map<String, dynamic> data) {
    var row = 2;
    
    // Résumé financier
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Résumé Financier')
      ..cellStyle = CellStyle(bold: true);
    
    row++;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Revenus totaux');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = DoubleCellValue(data['total_revenue']);
    
    row++;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Dépenses totales');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = DoubleCellValue(data['total_expenses']);
    
    row++;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Bénéfice net');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = DoubleCellValue(data['net_profit']);
  }

  // Contenu Excel pour le rapport des employés
  void _addEmployeeExcelContent(Sheet sheet, Map<String, dynamic> data) {
    var row = 2;
    
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Rapport des Employés')
      ..cellStyle = CellStyle(bold: true);
    
    row++;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Total des salaires');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = DoubleCellValue(data['salary_data']['total_salaries']);
  }

  // Contenu Excel pour le rapport des stocks
  void _addStockExcelContent(Sheet sheet, Map<String, dynamic> data) {
    var row = 2;
    
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Rapport des Stocks')
      ..cellStyle = CellStyle(bold: true);
    
    row++;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Articles en stock faible');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      ..value = IntCellValue((data['low_stock_items'] as List).length);
  }

  // Contenu Excel pour le rapport des cultures
  void _addCropExcelContent(Sheet sheet, Map<String, dynamic> data) {
    var row = 2;
    
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      ..value = TextCellValue('Rapport des Cultures')
      ..cellStyle = CellStyle(bold: true);
    
    // TODO: Implémenter le contenu du rapport des cultures
  }

  // Exporter un rapport
  Future<void> exportReport(ReportModel report) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Déterminer le format d'export par défaut (PDF)
      final format = report.exportFormat ?? ReportFormat.pdf;
      
      if (format == ReportFormat.pdf) {
        await exportToPdf(report);
      } else {
        await exportToExcel(report);
      }

      // Mettre à jour la date d'exportation
      await _supabase
          .from('reports')
          .update({
            'exported_at': DateTime.now().toIso8601String(),
            'export_format': format.toString().split('.').last,
          })
          .eq('id', report.id);

      await loadReports(); // Recharger la liste pour mettre à jour l'UI
    } catch (e) {
      error.value = 'Erreur lors de l\'exportation: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un rapport
  Future<void> deleteReport(String reportId) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _supabase
          .from('reports')
          .delete()
          .eq('id', reportId);

      reports.removeWhere((report) => report.id == reportId);
      Get.snackbar(
        'Succès',
        'Le rapport a été supprimé',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = 'Erreur lors de la suppression: $e';
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le rapport',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Afficher les détails d'un rapport
  void showReportDetails(ReportModel report) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Informations du rapport
              _buildReportInfo(report),
              const SizedBox(height: 24),
              // Graphique du rapport
              _buildReportChart(report),
              const SizedBox(height: 24),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => exportToPdf(report),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Exporter en PDF'),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () => exportToExcel(report),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Exporter en Excel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construire les informations du rapport
  Widget _buildReportInfo(ReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type: ${report.type.toString().split('.').last}'),
        const SizedBox(height: 8),
        Text(
          'Période: ${DateFormat('dd/MM/yyyy').format(report.startDate)} - ${DateFormat('dd/MM/yyyy').format(report.endDate)}',
        ),
        if (report.exportedAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Dernière exportation: ${DateFormat('dd/MM/yyyy HH:mm').format(report.exportedAt!)}',
          ),
        ],
      ],
    );
  }

  // Construire le graphique du rapport
  Widget _buildReportChart(ReportModel report) {
    switch (report.type) {
      case ReportType.finance:
        return _buildFinanceChart(report.data);
      case ReportType.employee:
        return _buildEmployeeChart(report.data);
      case ReportType.stock:
        return _buildStockChart(report.data);
      case ReportType.crop:
        return _buildCropChart(report.data);
    }
  }

  Widget _buildFinanceChart(Map<String, dynamic> data) {
    switch (selectedChartType.value) {
      case ChartType.bar:
        return _buildFinanceBarChart(data);
      case ChartType.pie:
        return _buildFinancePieChart(data);
      case ChartType.line:
        return _buildFinanceLineChart(data);
      default:
        return const Center(child: Text('Type de graphique non supporté'));
    }
  }

  Widget _buildFinanceBarChart(Map<String, dynamic> data) {
    final revenueByCategory = data['revenue_by_category'] as Map<String, dynamic>;
    final expensesByCategory = data['expenses_by_category'] as Map<String, dynamic>;
    
    final categories = {...revenueByCategory.keys, ...expensesByCategory.keys}.toList();
    final maxValue = [
      ...revenueByCategory.values.map((v) => v as double),
      ...expensesByCategory.values.map((v) => v as double),
    ].reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.2,
          barGroups: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: revenueByCategory[category]?.toDouble() ?? 0,
                  color: Colors.green,
                  width: 12,
                ),
                BarChartRodData(
                  toY: expensesByCategory[category]?.toDouble() ?? 0,
                  color: Colors.red,
                  width: 12,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compact().format(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < categories.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        categories[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildFinancePieChart(Map<String, dynamic> data) {
    final revenueByCategory = data['revenue_by_category'] as Map<String, dynamic>;
    final totalRevenue = revenueByCategory.values.fold<double>(0, (sum, value) => sum + (value as double));

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: revenueByCategory.entries.map((entry) {
            final value = entry.value as double;
            final percentage = (value / totalRevenue) * 100;
            return PieChartSectionData(
              color: Colors.primaries[revenueByCategory.keys.toList().indexOf(entry.key) % Colors.primaries.length],
              value: value,
              title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  Widget _buildFinanceLineChart(Map<String, dynamic> data) {
    final transactions = (data['transactions'] as List)
        .map((t) => Map<String, dynamic>.from(t))
        .toList();
    
    // Trier les transactions par date
    transactions.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
    
    // Calculer le solde cumulatif
    double balance = 0;
    final spots = transactions.map((t) {
      final amount = t['amount'] as double;
      final type = t['type'] as String;
      balance += type == 'income' ? amount : -amount;
      return FlSpot(
        DateTime.parse(t['date']).millisecondsSinceEpoch.toDouble(),
        balance,
      );
    }).toList();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryGreen,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryGreen.withOpacity(0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compact().format(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildEmployeeChart(Map<String, dynamic> data) {
    final performanceData = data['performance_data'] as Map<String, dynamic>? ?? {};
    
    switch (selectedChartType.value) {
      case ChartType.bar:
        return SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barGroups: performanceData.entries.map((entry) {
                final employeeId = entry.key;
                final performance = entry.value as Map<String, dynamic>;
                return BarChartGroupData(
                  x: performanceData.keys.toList().indexOf(employeeId),
                  barRods: [
                    BarChartRodData(
                      toY: performance['score']?.toDouble() ?? 0,
                      color: AppTheme.primaryGreen,
                      width: 16,
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value >= 0 && value < performanceData.length) {
                        final employeeId = performanceData.keys.elementAt(value.toInt());
                        final performance = performanceData[employeeId] as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            performance['employee_name'] as String? ?? 'Employé',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        );
      default:
        return const Center(child: Text('Type de graphique non supporté'));
    }
  }

  Widget _buildStockChart(Map<String, dynamic> data) {
    final stockItems = (data['stock_items'] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    
    switch (selectedChartType.value) {
      case ChartType.pie:
        return SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: stockItems.map((item) {
                final quantity = item['quantity'] as int;
                final totalQuantity = stockItems.fold<int>(
                  0,
                  (sum, item) => sum + (item['quantity'] as int),
                );
                final percentage = (quantity / totalQuantity) * 100;
                
                return PieChartSectionData(
                  color: Colors.primaries[stockItems.indexOf(item) % Colors.primaries.length],
                  value: quantity.toDouble(),
                  title: '${item['name']}\n${percentage.toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
            ),
          ),
        );
      default:
        return const Center(child: Text('Type de graphique non supporté'));
    }
  }

  Widget _buildCropChart(Map<String, dynamic> data) {
    // TODO: Implémenter les graphiques pour les cultures
    return const Center(
      child: Text('Graphiques des cultures à venir'),
    );
  }
} 