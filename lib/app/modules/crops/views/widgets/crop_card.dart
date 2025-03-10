import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/crop_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controllers/crops_controller.dart';

class CropCard extends StatelessWidget {
  final CropModel crop;
  final VoidCallback onTap;

  const CropCard({
    super.key,
    required this.crop,
    required this.onTap,
  });

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

  Color _getCategoryColor(CropCategory category) {
    switch (category) {
      case CropCategory.all:
        return Colors.grey;
      case CropCategory.foodCrops:
        return Colors.green;
      case CropCategory.marketGardens:
        return Colors.lightGreen;
      case CropCategory.fruitTrees:
        return Colors.orange;
      case CropCategory.industrialCrops:
        return Colors.brown;
      case CropCategory.fodderCrops:
        return Colors.lightBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CropsController>();
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de la culture
                  Image.network(
                    crop.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  // Overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Bouton favori
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Obx(() => Icon(
                        crop.isFavorite.value
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: crop.isFavorite.value
                            ? Colors.red
                            : Colors.white,
                      )),
                      onPressed: () => controller.toggleFavorite(crop),
                    ),
                  ),
                  // Compteur de vues
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.remove_red_eye_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Obx(() => Text(
                            '${crop.viewCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Informations
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom de la culture
                    Text(
                      crop.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Nom scientifique
                    Text(
                      crop.scientificName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Badge de catégorie
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(crop.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCategoryColor(crop.category),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getCategoryLabel(crop.category),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getCategoryColor(crop.category),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 