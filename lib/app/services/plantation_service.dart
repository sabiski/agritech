import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/plantation_model.dart';
import '../data/models/crop_model.dart';
import 'crop_service.dart';

class PlantationService extends GetxService {
  final supabase = Supabase.instance.client;
  final _cropService = Get.find<CropService>();
  
  // Liste des plantations
  final plantations = <PlantationModel>[].obs;
  
  // Filtres
  final selectedStatus = Rx<PlantationStatus?>(null);
  final searchQuery = ''.obs;
  
  // Plantations filtrées
  List<PlantationModel> get filteredPlantations {
    return plantations.where((plantation) {
      // Filtre par statut
      if (selectedStatus.value != null && 
          plantation.status.value != selectedStatus.value.toString().split('.').last) {
        return false;
      }
      
      // Filtre par recherche
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return plantation.name.toLowerCase().contains(query) ||
               plantation.description.toLowerCase().contains(query) ||
               plantation.crop.name.toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
  }
  
  // Charger toutes les plantations
  Future<void> loadPlantations() async {
    try {
      final response = await supabase
        .from('plantations')
        .select()
        .order('date_plantation', ascending: false);
        
      final List<PlantationModel> loadedPlantations = [];
      
      for (final json in response) {
        final crop = await _cropService.getCropById(json['crop_id']);
        if (crop != null) {
          final plantation = await PlantationModel.fromJson(json, crop);
          loadedPlantations.add(plantation);
        }
      }
      
      plantations.value = loadedPlantations;
    } catch (e) {
      print('Erreur lors du chargement des plantations: $e');
      rethrow;
    }
  }
  
  // Ajouter une plantation
  Future<void> addPlantation(PlantationModel plantation) async {
    try {
      final response = await supabase
        .from('plantations')
        .insert(plantation.toJson())
        .select()
        .single();
        
      final crop = await _cropService.getCropById(response['crop_id']);
      if (crop != null) {
        final newPlantation = await PlantationModel.fromJson(response, crop);
        plantations.add(newPlantation);
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de la plantation: $e');
      rethrow;
    }
  }
  
  // Mettre à jour une plantation
  Future<void> updatePlantation(PlantationModel plantation) async {
    try {
      await supabase
        .from('plantations')
        .update(plantation.toJson())
        .eq('id', plantation.id);
        
      final index = plantations.indexWhere((p) => p.id == plantation.id);
      if (index != -1) {
        plantations[index] = plantation;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la plantation: $e');
      rethrow;
    }
  }
  
  // Supprimer une plantation
  Future<void> deletePlantation(String id) async {
    try {
      await supabase
        .from('plantations')
        .delete()
        .eq('id', id);
        
      plantations.removeWhere((plantation) => plantation.id == id);
    } catch (e) {
      print('Erreur lors de la suppression de la plantation: $e');
      rethrow;
    }
  }
  
  // Ajouter une note au journal
  Future<void> addJournalEntry(PlantationModel plantation, String note) async {
    try {
      final newJournal = Map<DateTime, String>.from(plantation.journal)
        ..addAll({DateTime.now(): note});
        
      final updatedPlantation = PlantationModel(
        id: plantation.id,
        userId: plantation.userId,
        crop: plantation.crop,
        name: plantation.name,
        description: plantation.description,
        surface: plantation.surface,
        datePlantation: plantation.datePlantation,
        dateRecolteEstimee: plantation.dateRecolteEstimee,
        progression: plantation.progression.value,
        status: plantation.status.value,
        notes: plantation.notes,
        journal: newJournal,
        parametres: plantation.parametres,
      );
      
      await updatePlantation(updatedPlantation);
    } catch (e) {
      print('Erreur lors de l\'ajout de la note: $e');
      rethrow;
    }
  }
  
  // Mettre à jour le statut
  Future<void> updateStatus(PlantationModel plantation, String newStatus) async {
    try {
      plantation.status.value = newStatus;
      await updatePlantation(plantation);
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      rethrow;
    }
  }
  
  // Mettre à jour la progression
  Future<void> updateProgression(PlantationModel plantation, double newProgression) async {
    try {
      plantation.progression.value = newProgression;
      await updatePlantation(plantation);
    } catch (e) {
      print('Erreur lors de la mise à jour de la progression: $e');
      rethrow;
    }
  }
} 