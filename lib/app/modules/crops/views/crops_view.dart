import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/crops_controller.dart';
import '../../../data/models/crop_model.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/crop_card.dart';
import 'widgets/crop_details.dart';
import 'widgets/yield_calculator.dart';
import 'widgets/crop_search_delegate.dart';
import 'widgets/crop_form.dart';

class CropsView extends GetView<CropsController> {
  const CropsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width < 600
          ? AppBar(
              title: const Text('Cultures'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // TODO: Implémenter la recherche mobile
                    showSearch(
                      context: context,
                      delegate: CropSearchDelegate(controller),
                    );
                  },
                ),
              ],
            )
          : null,
      drawer: MediaQuery.of(context).size.width < 600
          ? _buildCategoriesDrawer(context)
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobileLayout(context);
          }
          return _buildDesktopLayout(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Ouvrir le formulaire d'ajout de culture
          _showAddCropDialog(context);
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      final crops = controller.filteredCrops;
      if (crops.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune culture trouvée',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Essayez de modifier vos critères de recherche',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }
      
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          return CropCard(
            crop: crop,
            onTap: () {
              controller.selectCrop(crop);
              Get.dialog(
                CropDetailsDialog(crop: crop),
                barrierDismissible: true,
              );
            },
          );
        },
      );
    });
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Menu latéral des catégories
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: _buildCategoriesContent(context),
        ),
        // Liste des cultures
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final crops = controller.filteredCrops;
            if (crops.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune culture trouvée',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Essayez de modifier vos critères de recherche',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];
                return CropCard(
                  crop: crop,
                  onTap: () {
                    controller.selectCrop(crop);
                    Get.dialog(
                      CropDetailsDialog(crop: crop),
                      barrierDismissible: true,
                    );
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoriesDrawer(BuildContext context) {
    return Drawer(
      child: _buildCategoriesContent(context),
    );
  }

  Widget _buildCategoriesContent(BuildContext context) {
    return Column(
      children: [
        // En-tête
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cultures',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Explorez notre catalogue de cultures adaptées au Gabon',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Rechercher une culture...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Liste des catégories
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildCategoryTile(
                context,
                null,
                'Toutes les cultures',
                Icons.grid_view_rounded,
              ),
              _buildCategoryTile(
                context,
                CropCategory.foodCrops,
                'Cultures Vivrières',
                Icons.grass_rounded,
              ),
              _buildCategoryTile(
                context,
                CropCategory.marketGardens,
                'Cultures Maraîchères',
                Icons.local_florist_rounded,
              ),
              _buildCategoryTile(
                context,
                CropCategory.fruitTrees,
                'Cultures Fruitières',
                Icons.eco_rounded,
              ),
              _buildCategoryTile(
                context,
                CropCategory.industrialCrops,
                'Cultures Industrielles',
                Icons.attach_money_rounded,
              ),
              _buildCategoryTile(
                context,
                CropCategory.fodderCrops,
                'Cultures Fourragères',
                Icons.grass_rounded,
              ),
            ],
          ),
        ),
        // Calculateur de rendement
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calculateur de Rendement',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Estimez vos rendements et revenus potentiels',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(
                    const YieldCalculatorDialog(),
                    barrierDismissible: true,
                  );
                },
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('Ouvrir le calculateur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddCropDialog(BuildContext context) {
    Get.dialog(
      const CropForm(),
      barrierDismissible: true,
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    CropCategory? category,
    String title,
    IconData icon,
  ) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == category;
      return ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryGreen : null,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppTheme.primaryGreen : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
        selected: isSelected,
        selectedColor: AppTheme.primaryGreen,
        onTap: () => controller.setCategory(category),
      );
    });
  }
} 