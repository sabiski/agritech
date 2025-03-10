import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/stock_controller.dart';
import '../../../../data/models/stock_model.dart';
import 'stock_item.dart';

class StockList extends GetView<StockController> {
  const StockList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.stocks.isEmpty) {
        return const Center(
          child: Text('Aucun stock disponible'),
        );
      }

      final stocks = controller.filteredStocks;
      if (stocks.isEmpty) {
        return const Center(
          child: Text('Aucun résultat trouvé'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StockItem(stock: stock),
          );
        },
      );
    });
  }
} 