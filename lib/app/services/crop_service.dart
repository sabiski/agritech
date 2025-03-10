import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/crop_model.dart';

class CropService extends GetxService {
  final _supabase = Supabase.instance.client;
  
  // Liste observable des cultures
  final crops = <CropModel>[].obs;
  
  // Filtres
  final selectedCategory = Rx<CropCategory?>(null);
  final searchQuery = ''.obs;
  
  // Cultures filtrées
  List<CropModel> get filteredCrops {
    var filtered = crops.toList();
    
    // Filtrer par catégorie si sélectionnée
    if (selectedCategory.value != null) {
      filtered = filtered.where((crop) => crop.category == selectedCategory.value).toList();
    }
    
    // Filtrer par recherche si query non vide
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((crop) {
        return crop.name.toLowerCase().contains(query) ||
               crop.scientificName.toLowerCase().contains(query);
      }).toList();
    }
    
    return filtered;
  }
  
  // Charger les cultures depuis Supabase
  Future<void> loadCrops() async {
    try {
      final response = await _supabase
          .from('crops')
          .select()
          .order('name');
          
      crops.value = response.map((json) => CropModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading crops: $e');
      rethrow;
    }
  }

  // Récupérer une culture par son ID
  Future<CropModel?> getCropById(String id) async {
    try {
      final response = await _supabase
          .from('crops')
          .select()
          .eq('id', id)
          .single();
          
      return CropModel.fromJson(response);
    } catch (e) {
      print('Error getting crop by id: $e');
      return null;
    }
  }
  
  // Incrémenter le compteur de vues
  Future<void> incrementViewCount(CropModel crop) async {
    try {
      final newCount = crop.viewCount.value + 1;
      await _supabase
          .from('crops')
          .update({'view_count': newCount})
          .eq('id', crop.id);
          
      // Mettre à jour localement
      final index = crops.indexWhere((c) => c.id == crop.id);
      if (index != -1) {
        final updatedCrop = crop.copyWith(viewCount: newCount);
        crops[index] = updatedCrop;
      }
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }
  
  // Marquer/Démarquer comme favori
  Future<void> toggleFavorite(CropModel crop) async {
    try {
      final newValue = !crop.isFavorite.value;
      await _supabase
          .from('crops')
          .update({'is_favorite': newValue})
          .eq('id', crop.id);
          
      // Mettre à jour localement
      final index = crops.indexWhere((c) => c.id == crop.id);
      if (index != -1) {
        final updatedCrop = crop.copyWith(isFavorite: newValue);
        crops[index] = updatedCrop;
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }
  
  // Calculer le rendement potentiel
  double calculatePotentialYield({
    required CropModel crop,
    required double area,
    double efficiency = 0.8, // Efficacité par défaut de 80%
  }) {
    return crop.averageYield * area * efficiency;
  }
  
  // Calculer le revenu potentiel
  double calculatePotentialRevenue({
    required CropModel crop,
    required double yield,
    double priceMultiplier = 1.0, // Multiplicateur de prix par défaut
  }) {
    return yield * crop.averagePrice * priceMultiplier;
  }

  // Ajouter une culture
  Future<void> addCrop(CropModel crop) async {
    try {
      final response = await _supabase
          .from('crops')
          .insert(crop.toJson())
          .select()
          .single();
          
      final newCrop = CropModel.fromJson(response);
      crops.add(newCrop);
    } catch (e) {
      print('Error adding crop: $e');
      rethrow;
    }
  }

  // Mettre à jour une culture
  Future<void> updateCrop(CropModel crop) async {
    try {
      final response = await _supabase
          .from('crops')
          .update(crop.toJson())
          .eq('id', crop.id)
          .select()
          .single();
          
      final updatedCrop = CropModel.fromJson(response);
      final index = crops.indexWhere((c) => c.id == crop.id);
      if (index != -1) {
        crops[index] = updatedCrop;
      }
    } catch (e) {
      print('Error updating crop: $e');
      rethrow;
    }
  }

  // Supprimer une culture
  Future<void> deleteCrop(String id) async {
    try {
      await _supabase
          .from('crops')
          .delete()
          .eq('id', id);
          
      crops.removeWhere((crop) => crop.id == id);
    } catch (e) {
      print('Error deleting crop: $e');
      rethrow;
    }
  }
} 