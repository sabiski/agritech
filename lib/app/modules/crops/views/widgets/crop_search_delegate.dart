import 'package:flutter/material.dart';
import '../../controllers/crops_controller.dart';
import '../../../../data/models/crop_model.dart';
import 'crop_card.dart';
import 'crop_details.dart';
import 'package:get/get.dart';

class CropSearchDelegate extends SearchDelegate {
  final CropsController controller;

  CropSearchDelegate(this.controller);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    controller.setSearchQuery(query);
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    controller.setSearchQuery(query);
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return Obx(() {
      final crops = controller.filteredCrops;
      
      if (crops.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Get.theme.disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune culture trouvée',
                style: Get.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Essayez avec un autre terme',
                style: Get.textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(crop.imageUrl),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
            title: Text(crop.name),
            subtitle: Text(crop.scientificName),
            onTap: () {
              controller.selectCrop(crop);
              close(context, null);
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
} 