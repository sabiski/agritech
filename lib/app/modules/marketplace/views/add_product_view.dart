import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/marketplace_controller.dart';
import '../../../core/theme/app_theme.dart';

class AddProductView extends GetView<MarketplaceController> {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter un produit',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section photos
            _buildSectionTitle('Photos du produit'),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 24),

            // Informations de base
            _buildSectionTitle('Informations de base'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: _inputDecoration(
                'Nom du produit',
                'Ex: Tomates fraîches',
                Icons.shopping_bag_outlined,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: _inputDecoration(
                'Description',
                'Décrivez votre produit en détail',
                Icons.description_outlined,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      'Prix',
                      'Ex: 1000',
                      Icons.attach_money,
                      suffix: 'FCFA',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: _inputDecoration(
                      'Unité',
                      'Ex: kg',
                      Icons.scale_outlined,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Catégorisation
            _buildSectionTitle('Catégorisation'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(
                'Type de produit',
                null,
                Icons.category_outlined,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'agricultural',
                  child: Text('Produit agricole'),
                ),
                DropdownMenuItem(
                  value: 'input',
                  child: Text('Intrant'),
                ),
              ],
              onChanged: (value) {
                // TODO: Gérer le changement
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(
                'Catégorie',
                null,
                Icons.grid_view_outlined,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'vegetables',
                  child: Text('Légumes'),
                ),
                DropdownMenuItem(
                  value: 'fruits',
                  child: Text('Fruits'),
                ),
                DropdownMenuItem(
                  value: 'cereals',
                  child: Text('Céréales'),
                ),
                DropdownMenuItem(
                  value: 'tools',
                  child: Text('Outils'),
                ),
                DropdownMenuItem(
                  value: 'fertilizers',
                  child: Text('Engrais'),
                ),
              ],
              onChanged: (value) {
                // TODO: Gérer le changement
              },
            ),
            const SizedBox(height: 24),

            // Stock et disponibilité
            _buildSectionTitle('Stock et disponibilité'),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'Quantité disponible',
                'Ex: 100',
                Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Produit en promotion'),
              subtitle: const Text('Mettre en avant dans les résultats de recherche'),
              value: false,
              onChanged: (bool value) {
                // TODO: Gérer le changement
              },
              activeColor: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 24),

            // Localisation
            _buildSectionTitle('Localisation'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: _inputDecoration(
                'Lieu de retrait',
                'Ex: Libreville, Quartier Louis',
                Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 32),

            // Bouton de publication
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Gérer la publication
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Publier l\'annonce',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    String? hint,
    IconData icon, {
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixText: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: 5, // Maximum 5 photos
        itemBuilder: (context, index) {
          // Si c'est le premier élément et qu'il n'y a pas de photo
          if (index == 0) {
            return Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: InkWell(
                onTap: () {
                  // TODO: Ouvrir le sélecteur d'images
                },
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.grey[600],
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ajouter',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // Pour les emplacements de photos supplémentaires
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
          );
        },
      ),
    );
  }
} 