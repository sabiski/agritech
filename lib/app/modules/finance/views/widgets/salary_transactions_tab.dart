import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/finance_controller.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../employee/controllers/employee_controller.dart';

class SalaryTransactionsTab extends StatefulWidget {
  const SalaryTransactionsTab({super.key});

  @override
  State<SalaryTransactionsTab> createState() => _SalaryTransactionsTabState();
}

class _SalaryTransactionsTabState extends State<SalaryTransactionsTab> {
  final FinanceController _financeController = Get.find<FinanceController>();
  final EmployeeController _employeeController = Get.find<EmployeeController>();
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  final RxString _selectedPeriod = 'all'.obs;
  final RxString _selectedEmployee = 'all'.obs;
  final RxList<TransactionModel> _filteredTransactions = <TransactionModel>[].obs;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadData();
    });

    ever(_selectedPeriod, (_) => _updateFilteredTransactions());
    ever(_selectedEmployee, (_) => _updateFilteredTransactions());
    ever(_financeController.transactions, (_) => _updateFilteredTransactions());
  }

  Future<void> _loadData() async {
    await _employeeController.fetchEmployees();
    await _financeController.fetchTransactions();
    _updateFilteredTransactions();
  }

  void _updateFilteredTransactions() {
    var transactions = _financeController.transactions
        .where((t) => t.category?.toLowerCase() == 'salaires')
        .toList();

    if (_selectedEmployee.value != 'all') {
      transactions = transactions.where((t) => 
        t.metadata?['employee_id'] == _selectedEmployee.value
      ).toList();
    }

    final now = DateTime.now();
    switch (_selectedPeriod.value) {
      case 'this_month':
        transactions = transactions.where((t) =>
          t.date.year == now.year && t.date.month == now.month
        ).toList();
        break;
      case 'last_month':
        final lastMonth = DateTime(now.year, now.month - 1);
        transactions = transactions.where((t) =>
          t.date.year == lastMonth.year && t.date.month == lastMonth.month
        ).toList();
        break;
      case 'last_3_months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3);
        transactions = transactions.where((t) =>
          t.date.isAfter(threeMonthsAgo)
        ).toList();
        break;
    }

    _filteredTransactions.value = transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSalaryChart(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: _buildSalaryTransactionsList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtres',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod.value,
                    decoration: const InputDecoration(
                      labelText: 'Période',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Toutes les périodes'),
                      ),
                      DropdownMenuItem(
                        value: 'this_month',
                        child: Text('Ce mois'),
                      ),
                      DropdownMenuItem(
                        value: 'last_month',
                        child: Text('Mois dernier'),
                      ),
                      DropdownMenuItem(
                        value: 'last_3_months',
                        child: Text('3 derniers mois'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) _selectedPeriod.value = value;
                    },
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: Obx(() {
                    final employees = _employeeController.employees;
                    return DropdownButtonFormField<String>(
                      value: _selectedEmployee.value,
                      decoration: const InputDecoration(
                        labelText: 'Employé',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text('Tous les employés'),
                        ),
                        ...employees.map((employee) => DropdownMenuItem(
                          value: employee.id,
                          child: Text(
                            employee.fullName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        if (value != null) _selectedEmployee.value = value;
                      },
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryChart() {
    return Obx(() {
      final transactions = _filteredTransactions;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Évolution des salaires',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Pas de données disponibles',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildChart(transactions),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChart(List<TransactionModel> transactions) {
    final monthlyData = <DateTime, double>{};
    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
      );
      monthlyData[date] = (monthlyData[date] ?? 0) + transaction.amount;
    }

    final sortedDates = monthlyData.keys.toList()..sort((a, b) => a.compareTo(b));

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 80,
              getTitlesWidget: (value, meta) {
                return Text(
                  currencyFormat.format(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                  final date = sortedDates[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MMM yy').format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(sortedDates.length, (index) {
              final date = sortedDates[index];
              return FlSpot(
                index.toDouble(),
                monthlyData[date]!,
              );
            }),
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
      ),
    );
  }

  Widget _buildSalaryTransactionsList() {
    return Obx(() {
      final transactions = _filteredTransactions;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Transactions salariales',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    'Total: ${currencyFormat.format(transactions.fold<double>(0, (sum, t) => sum + t.amount))}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune transaction salariale',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return _buildTransactionItem(transaction);
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final employeeInfo = transaction.metadata?['employee_id'] != null
        ? _getEmployeeName(transaction.metadata!['employee_id'])
        : 'Employé inconnu';

    return ListTile(
      title: Text(transaction.description ?? 'Transaction salariale'),
      subtitle: Text(employeeInfo),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currencyFormat.format(transaction.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('dd/MM/yyyy').format(transaction.date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () => _showTransactionDetails(transaction),
    );
  }

  String _getEmployeeName(String employeeId) {
    final employee = _employeeController.employees
        .firstWhereOrNull((e) => e.id == employeeId);
    return employee?.fullName ?? 'Employé inconnu';
  }

  void _showTransactionDetails(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détails de la transaction',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Date', DateFormat('dd/MM/yyyy').format(transaction.date)),
              _buildDetailRow('Montant', currencyFormat.format(transaction.amount)),
              _buildDetailRow('Type', 'Dépense'),
              _buildDetailRow('Catégorie', 'Salaires'),
              if (transaction.metadata != null) ...[
                const Divider(height: 32),
                Text(
                  'Détails du salaire',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Salaire de base', 
                  currencyFormat.format(transaction.metadata!['base_amount'] ?? 0)),
                _buildDetailRow('Bonus', 
                  currencyFormat.format(transaction.metadata!['bonus_amount'] ?? 0)),
                if (transaction.metadata!['performance_metrics'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Métriques de performance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildPerformanceMetrics(
                    transaction.metadata!['performance_metrics'] as Map<String, dynamic>
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(Map<String, dynamic> metrics) {
    return Column(
      children: [
        _buildDetailRow('Tâches totales', metrics['total_tasks'].toString()),
        _buildDetailRow('Complétées à temps', metrics['completed_on_time'].toString()),
        _buildDetailRow('Tâches en retard', metrics['overdue_tasks'].toString()),
        _buildDetailRow(
          'Taux de réussite',
          '${(metrics['on_time_completion_rate'] * 100).toStringAsFixed(0)}%',
        ),
      ],
    );
  }
} 