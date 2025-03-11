import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/finance_controller.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/finance_stats.dart';
import 'widgets/transaction_list.dart';
import 'widgets/transaction_form.dart';
import 'widgets/transaction_item.dart';
import 'widgets/salary_transactions_tab.dart';
import '../../../data/models/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';

class FinanceView extends GetView<FinanceController> {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.offAllNamed('/farmer');
            },
          ),
          title: const Text('Gestion des Finances'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.account_balance_wallet),
                text: 'Transactions',
              ),
              Tab(
                icon: Icon(Icons.payments),
                text: 'Salaires',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTransactionDialog(context),
          backgroundColor: AppTheme.primaryGreen,
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle transaction'),
        ),
        body: TabBarView(
          children: [
            _buildTransactionsTab(),
            const SalaryTransactionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Builder(
      builder: (context) => Column(
        children: [
          // En-tête avec statistiques
          const FinanceStats(),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Graphique
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    child: Obx(() {
                      if (controller.transactions.isEmpty) {
                        return const Center(
                          child: Text('Pas de données disponibles'),
                        );
                      }

                      return LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
                                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        months[value.toInt()],
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Revenus
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 1.5),
                                FlSpot(1, 2.0),
                                FlSpot(2, 1.8),
                                FlSpot(3, 2.5),
                                FlSpot(4, 2.2),
                                FlSpot(5, 3.0),
                              ],
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green.withOpacity(0.1),
                              ),
                            ),
                            // Dépenses
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 1.0),
                                FlSpot(1, 1.2),
                                FlSpot(2, 1.4),
                                FlSpot(3, 1.6),
                                FlSpot(4, 1.8),
                                FlSpot(5, 2.0),
                              ],
                              isCurved: true,
                              color: Colors.red,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.red.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  
                  // Filtres
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        // Barre de recherche
                        SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Rechercher une transaction...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onChanged: controller.updateSearch,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Filtres
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            Flexible(
                              child: Container(
                                height: 40,
                                constraints: const BoxConstraints(minWidth: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Obx(() => DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: controller.selectedType.value,
                                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                                    items: controller.types.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                          type,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.updateSelectedType(value);
                                      }
                                    },
                                  ),
                                )),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 40,
                                constraints: const BoxConstraints(minWidth: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Obx(() => DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: controller.selectedCategory.value,
                                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                                    items: controller.categories.map((category) {
                                      return DropdownMenuItem(
                                        value: category,
                                        child: Text(
                                          category,
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.updateSelectedCategory(value);
                                      }
                                    },
                                  ),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Liste des transactions
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 500,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          // Vue mobile : une colonne
                          return const TransactionList();
                        } else {
                          // Vue desktop : deux colonnes
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Revenus',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Obx(() {
                                          final incomeTransactions = controller.filteredTransactions
                                              .where((t) => t.type == TransactionType.income)
                                              .toList();
                                          return ListView.builder(
                                            padding: const EdgeInsets.only(right: 8),
                                            itemCount: incomeTransactions.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: TransactionItem(
                                                  transaction: incomeTransactions[index],
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Dépenses',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Obx(() {
                                          final expenseTransactions = controller.filteredTransactions
                                              .where((t) => t.type == TransactionType.expense)
                                              .toList();
                                          return ListView.builder(
                                            padding: const EdgeInsets.only(left: 8),
                                            itemCount: expenseTransactions.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: TransactionItem(
                                                  transaction: expenseTransactions[index],
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const TransactionForm(),
        ),
      ),
    );
  }
} 