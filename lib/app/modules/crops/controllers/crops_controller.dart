import 'package:get/get.dart';
import '../../../data/models/crop_model.dart';
import '../../../services/crop_service.dart';

class CropsController extends GetxController {
  final CropService _cropService = Get.find<CropService>();
  
  // État de chargement
  final isLoading = false.obs;
  
  // Culture sélectionnée pour les détails
  final selectedCrop = Rx<CropModel?>(null);
  
  // Getter pour la catégorie sélectionnée
  Rx<CropCategory?> get selectedCategory => _cropService.selectedCategory;
  
  // Filtres
  void setCategory(CropCategory? category) {
    _cropService.selectedCategory.value = category;
  }
  
  void setSearchQuery(String query) {
    _cropService.searchQuery.value = query;
  }
  
  // Cultures filtrées
  List<CropModel> get filteredCrops => _cropService.filteredCrops;
  
  // Cultures par catégorie
  List<CropModel> getCropsByCategory(CropCategory category) {
    return _cropService.crops.where((crop) => crop.category == category).toList();
  }
  
  // Charger les cultures
  Future<void> loadCrops() async {
    try {
      isLoading.value = true;
      await _cropService.loadCrops();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Sélectionner une culture pour voir les détails
  void selectCrop(CropModel crop) async {
    selectedCrop.value = crop;
    await _cropService.incrementViewCount(crop);
  }
  
  // Marquer/Démarquer comme favori
  Future<void> toggleFavorite(CropModel crop) async {
    await _cropService.toggleFavorite(crop);
  }
  
  // Calculateur de rendement
  double calculateYield(CropModel crop, double area) {
    return _cropService.calculatePotentialYield(
      crop: crop,
      area: area,
    );
  }
  
  // Calculateur de revenu
  double calculateRevenue(CropModel crop, double yield) {
    return _cropService.calculatePotentialRevenue(
      crop: crop,
      yield: yield,
    );
  }

  // Ajouter une culture
  Future<void> addCrop(CropModel crop) async {
    try {
      isLoading.value = true;
      await _cropService.addCrop(crop);
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour une culture
  Future<void> updateCrop(CropModel crop) async {
    try {
      isLoading.value = true;
      await _cropService.updateCrop(crop);
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer une culture
  Future<void> deleteCrop(String id) async {
    try {
      isLoading.value = true;
      await _cropService.deleteCrop(id);
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  void onInit() {
    super.onInit();
    loadCrops();
  }
} 