import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../data/models/crop_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controllers/crops_controller.dart';

class CropForm extends StatefulWidget {
  final CropModel? crop;

  const CropForm({
    super.key,
    this.crop,
  });

  @override
  State<CropForm> createState() => _CropFormState();
}

class _CropFormState extends State<CropForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<CropsController>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _plantingMethodController;
  late final TextEditingController _maintenanceController;
  late final TextEditingController _harvestPeriodController;
  late final TextEditingController _averageYieldController;
  late final TextEditingController _averagePriceController;

  CropCategory _selectedCategory = CropCategory.foodCrops;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final crop = widget.crop;
    _nameController = TextEditingController(text: crop?.name);
    _descriptionController = TextEditingController(text: crop?.description);
    _plantingMethodController = TextEditingController(text: crop?.plantingMethod);
    _maintenanceController = TextEditingController(text: crop?.maintenance);
    _harvestPeriodController = TextEditingController(text: crop?.harvestPeriod);
    _averageYieldController = TextEditingController(
      text: crop?.averageYield.toString(),
    );
    _averagePriceController = TextEditingController(
      text: crop?.averagePrice.toString(),
    );

    if (crop != null) {
      _selectedCategory = crop.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _plantingMethodController.dispose();
    _maintenanceController.dispose();
    _harvestPeriodController.dispose();
    _averageYieldController.dispose();
    _averagePriceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final crop = CropModel(
      id: widget.crop?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      scientificName: '', // Sera rempli par l'administrateur
      description: _descriptionController.text,
      origin: '', // Sera rempli par l'administrateur
      imageUrl: '', // Sera ajouté via le diagnostic photo
      category: _selectedCategory,
      soilType: '', // Sera rempli par l'administrateur
      waterNeeds: '', // Sera rempli par l'administrateur
      climate: '', // Sera rempli par l'administrateur
      temperature: '', // Sera rempli par l'administrateur
      plantingMethod: _plantingMethodController.text,
      spacing: '', // Sera rempli par l'administrateur
      growthCycle: '', // Sera rempli par l'administrateur
      maintenance: _maintenanceController.text,
      pests: '', // Sera rempli par l'administrateur
      diseases: '', // Sera rempli par l'administrateur
      harvestPeriod: _harvestPeriodController.text,
      averageYield: double.tryParse(_averageYieldController.text) ?? 0,
      averagePrice: double.tryParse(_averagePriceController.text) ?? 0,
    );

    try {
      if (widget.crop == null) {
        await _controller.addCrop(crop);
        Get.back();
        Get.snackbar(
          'Succès',
          'Culture ajoutée avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await _controller.updateCrop(crop);
        Get.back();
        Get.snackbar(
          'Succès',
          'Culture mise à jour avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.crop == null ? 'Ajouter une culture' : 'Modifier la culture',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            // Message d'information
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Remplissez uniquement les informations que vous connaissez. Les détails techniques seront complétés par nos experts.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Formulaire
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom de la culture
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nom de la culture',
                        hint: 'Ex: Manioc, Maïs, Tomate...',
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      
                      // Catégorie
                      _buildDropdownField(
                        label: 'Type de culture',
                        hint: 'Choisissez le type de culture',
                        value: _selectedCategory,
                        items: CropCategory.values.where((c) => c != CropCategory.all).map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryLabel(category)),
                          );
                        }).toList(),
                        onChanged: (CropCategory? value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description simple',
                        hint: 'Décrivez la culture en quelques mots...',
                        maxLines: 3,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      // Méthode de plantation
                      _buildTextField(
                        controller: _plantingMethodController,
                        label: 'Comment planter',
                        hint: 'Expliquez comment vous plantez habituellement...',
                        maxLines: 3,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      // Entretien
                      _buildTextField(
                        controller: _maintenanceController,
                        label: 'Entretien habituel',
                        hint: 'Décrivez comment vous entretenez la culture...',
                        maxLines: 3,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      // Période de récolte
                      _buildTextField(
                        controller: _harvestPeriodController,
                        label: 'Quand récolter',
                        hint: 'Ex: 3-4 mois après la plantation',
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      // Rendement et prix
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _averageYieldController,
                              label: 'Rendement habituel',
                              hint: 'Tonnes par hectare',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _averagePriceController,
                              label: 'Prix moyen',
                              hint: 'FCFA par kg',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Boutons d'action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 48),
                    ),
                    child: Text(
                      widget.crop == null ? 'Ajouter' : 'Mettre à jour',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    int? maxLines,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  String _getCategoryLabel(CropCategory category) {
    switch (category) {
      case CropCategory.all:
        return 'Toutes les cultures';
      case CropCategory.foodCrops:
        return 'Cultures vivrières';
      case CropCategory.marketGardens:
        return 'Cultures maraîchères';
      case CropCategory.fruitTrees:
        return 'Arbres fruitiers';
      case CropCategory.industrialCrops:
        return 'Cultures industrielles';
      case CropCategory.fodderCrops:
        return 'Cultures fourragères';
    }
  }
} 