import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/marketplace_controller.dart';
import '../models/product_model.dart';
import '../../../core/theme/app_theme.dart';

class AddProductView extends GetView<MarketplaceController> {
  AddProductView({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _selectedImages = <dynamic>[].obs;
  final _isPromotion = false.obs;
  final _promoPrice = TextEditingController();
  final _selectedCategory = Rx<ProductCategory?>(null);
  final _selectedType = Rx<ProductType?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter un produit',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              Text(
                'Images du produit',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => _selectedImages.isEmpty
                ? _buildAddImageButton()
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          return _buildAddImageButton();
                        }
                        return _buildImagePreview(_selectedImages[index], index);
                      },
                    ),
                  ),
              ),
              const SizedBox(height: 24),

              // Informations de base
              Text(
                'Informations de base',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Catégorie et Type
              LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth > 600 
                        ? (constraints.maxWidth - 32) / 2 
                        : constraints.maxWidth,
                      child: DropdownButtonFormField<ProductCategory>(
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategory.value,
                        items: ProductCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => _selectedCategory.value = value,
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner une catégorie';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 600 
                        ? (constraints.maxWidth - 32) / 2 
                        : constraints.maxWidth,
                      child: DropdownButtonFormField<ProductType>(
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedType.value,
                        items: ProductType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => _selectedType.value = value,
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner un type';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nom et Description
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Prix et Quantité
              Text(
                'Prix et stock',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth > 600 
                        ? (constraints.maxWidth - 32) / 2 
                        : constraints.maxWidth,
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prix',
                          suffixText: 'FCFA',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un prix';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Prix invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 600 
                        ? (constraints.maxWidth - 32) / 2 
                        : constraints.maxWidth,
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantité disponible',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une quantité';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Quantité invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unité (kg, sac, etc.)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une unité';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Promotion
              Text(
                'Promotion',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => SwitchListTile(
                title: const Text('Mettre en promotion'),
                value: _isPromotion.value,
                onChanged: (bool value) {
                  _isPromotion.value = value;
                },
                activeColor: AppTheme.primary,
              )),
              Obx(() => _isPromotion.value
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextFormField(
                      controller: _promoPrice,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix promotionnel',
                        suffixText: 'FCFA',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_isPromotion.value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un prix promotionnel';
                          }
                          final promoPrice = double.tryParse(value);
                          final originalPrice = double.tryParse(_priceController.text);
                          if (promoPrice == null) {
                            return 'Prix invalide';
                          }
                          if (originalPrice != null && promoPrice >= originalPrice) {
                            return 'Le prix promotionnel doit être inférieur au prix original';
                          }
                        }
                        return null;
                      },
                    ),
                  )
                : const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              // Bouton de publication
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _publishProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Publier l\'annonce',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 32),
            SizedBox(height: 4),
            Text('Ajouter\nune image'),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(dynamic image, int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: kIsWeb && image is Uint8List
                ? MemoryImage(image)
                : FileImage(image as File) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: InkWell(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          _selectedImages.add(bytes);
        } else {
          _selectedImages.add(File(pickedFile.path));
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner l\'image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _removeImage(int index) {
    _selectedImages.removeAt(index);
  }

  Future<void> _publishProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez ajouter au moins une image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        promoPrice: _isPromotion.value ? double.parse(_promoPrice.text) : null,
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text,
        category: _selectedCategory.value!,
        type: _selectedType.value!,
        status: ProductStatus.available,
        sellerId: controller.currentUserId!,
        imageUrls: [], // Will be updated after image upload
        createdAt: DateTime.now(),
      );

      // Upload images and get URLs
      final imageUrls = await Future.wait(
        _selectedImages.map((image) => controller.uploadProductImage(image))
      );

      // Update product with image URLs
      final updatedProduct = product.copyWith(imageUrls: imageUrls);

      // Add product to database
      await controller.addProduct(updatedProduct);

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la publication',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error publishing product: $e');
    }
  }
} 