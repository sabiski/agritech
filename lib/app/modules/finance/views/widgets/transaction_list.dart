import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/finance_controller.dart';
import 'transaction_item.dart';

class TransactionList extends GetView<FinanceController> {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.transactions.isEmpty) {
        return const Center(
          child: Text('Aucune transaction disponible'),
        );
      }

      final transactions = controller.filteredTransactions;
      if (transactions.isEmpty) {
        return const Center(
          child: Text('Aucun résultat trouvé'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TransactionItem(transaction: transaction),
          );
        },
      );
    });
  }
} 