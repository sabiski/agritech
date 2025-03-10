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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAllNamed('/farmer');
          },
        ),
        title: const Text('Gestion des Stocks'),
      ),
      // Ajout du Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStockDialog(context),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau produit'),
      ),
      body: Column(
        children: [
          // En-tête avec statistiques
          const StockStats(),
          
          // Filtres
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: controller.updateSearch,
                ),
                const SizedBox(height: 16),
                // Filtre par catégorie
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => DropdownButton<String>(
                    isExpanded: true,
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
                ),
              ],
            ),
          ),

          // Liste des stocks avec message quand vide
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.stocks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun stock disponible',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Commencez par ajouter un produit',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddStockDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un produit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final filteredStocks = controller.filteredStocks;
              if (filteredStocks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun résultat trouvé',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const StockList();
            }),
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