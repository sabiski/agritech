import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stock_controller.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/stock_list.dart';
import 'widgets/stock_form.dart';
import 'widgets/stock_stats.dart';

class StockView extends GetView<StockController> {
  const StockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Stocks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddStockDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          const StockStats(),
          
          // Filtres
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Barre de recherche
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: controller.updateSearch,
                  ),
                ),
                const SizedBox(width: 16),
                // Filtre par catégorie
                Obx(() => DropdownButton<String>(
                  value: controller.selectedCategory.value,
                  items: controller.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateSelectedCategory(value);
                    }
                  },
                )),
              ],
            ),
          ),

          // Liste des stocks
          const Expanded(
            child: StockList(),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(16),
          child: const StockForm(),
        ),
      ),
    );
  }
} 