import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/marketplace_controller.dart';
import '../../../core/theme/app_theme.dart';

class MarketplaceView extends GetView<MarketplaceController> {
  const MarketplaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar personnalisée
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Rechercher des produits, intrants...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () {
                        // TODO: Ouvrir les filtres avancés
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                ),
              ),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Get.toNamed('/marketplace/cart'),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Obx(() => Text(
                        '${controller.cart.value.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined),
                onPressed: () => Get.toNamed('/marketplace/orders'),
              ),
            ],
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Bannières promotionnelles
                SizedBox(
                  height: 180,
                  child: PageView(
                    controller: PageController(viewportFraction: 0.92),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildPromoBanner(
                          'Produits locaux',
                          'Découvrez les meilleurs produits de votre région',
                          Icons.eco_outlined,
                          Colors.green.shade900,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildPromoBanner(
                          'Intrants agricoles',
                          'Tout pour votre exploitation',
                          Icons.agriculture_outlined,
                          Colors.brown.shade800,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildPromoBanner(
                          'Vente directe',
                          'Du producteur au consommateur',
                          Icons.store_outlined,
                          Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Catégories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catégories',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCategoryCard(
                              'Légumes',
                              Icons.eco,
                              Colors.green,
                            ),
                            _buildCategoryCard(
                              'Fruits',
                              Icons.apple,
                              Colors.orange,
                            ),
                            _buildCategoryCard(
                              'Semences',
                              Icons.grass,
                              Colors.lightGreen,
                            ),
                            _buildCategoryCard(
                              'Engrais',
                              Icons.science,
                              Colors.blue,
                            ),
                            _buildCategoryCard(
                              'Outils',
                              Icons.handyman,
                              Colors.brown,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Filtres rapides
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Tous', isSelected: true),
                      _buildFilterChip('Produits agricoles'),
                      _buildFilterChip('Intrants'),
                      _buildFilterChip('Nouveautés'),
                      _buildFilterChip('Promotions'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // En-tête des produits
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Produits populaires',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Voir tous les produits
                        },
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Grille de produits
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.error.value.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.error.value,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.fetchProducts,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final products = controller.filteredProducts;
              if (products.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun produit trouvé',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (controller.searchQuery.value.isNotEmpty ||
                            controller.selectedCategory.value != 'Tous' ||
                            controller.selectedType.value != 'Tous')
                          TextButton(
                            onPressed: _resetFilters,
                            child: const Text('Réinitialiser les filtres'),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return _buildProductCard(product);
                  },
                  childCount: products.length,
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/marketplace/add-product'),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Vendre'),
      ),
    );
  }

  Widget _buildPromoBanner(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            top: 50,
            child: Icon(
              icon,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Réinitialiser les filtres
  void _resetFilters() {
    controller.searchQuery.value = '';
    controller.setCategory('Tous');
    controller.setType('Tous');
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => controller.setCategory(title),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          if (label == 'Tous') {
            _resetFilters();
          } else if (label == 'Produits agricoles' || label == 'Intrants') {
            controller.setType(label);
          }
        },
        selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          '/marketplace/product-details',
          arguments: product,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image et badge de promotion
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: product.imageUrls.isNotEmpty
                      ? Hero(
                          tag: 'product-${product.id}',
                          child: Image.network(
                            product.imageUrls[0],
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                ),
                if (product.isPromoted ?? false)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PROMO',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type de produit
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.type == 'agricultural'
                          ? AppTheme.primaryGreen.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.type == 'agricultural'
                          ? 'Produit agricole'
                          : 'Intrant',
                      style: TextStyle(
                        color: product.type == 'agricultural'
                            ? AppTheme.primaryGreen
                            : Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Nom du produit
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Prix
                  Row(
                    children: [
                      Text(
                        '${product.price} FCFA',
                        style: GoogleFonts.poppins(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '/${product.unit}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Localisation et note
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.location,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 