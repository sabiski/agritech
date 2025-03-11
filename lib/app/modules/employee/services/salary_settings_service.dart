import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/salary_settings_model.dart';
import '../../../services/auth_service.dart';
import 'package:flutter/material.dart';

class SalarySettingsService extends GetxService {
  final _supabase = Supabase.instance.client;
  final _authService = Get.find<AuthService>();
  final Rx<SalarySettingsModel> settings = SalarySettingsModel().obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Initialiser les paramètres par défaut
  Future<void> initializeDefaultSettings() async {
    try {
      final farmerId = _authService.currentUser?.id.toString();
      if (farmerId == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final defaultSettings = SalarySettingsModel(
        farmerId: farmerId,
        excellentPerformanceRate: 0.9,
        goodPerformanceRate: 0.7,
        onTimeCompletionBonus: 0.1,
        overdueTaskPenalty: 0.05,
        productivityTaskThreshold: 10,
        productivityCompletionThreshold: 8,
        highProductivityBonus: 0.15,
        maxTotalBonus: 0.3,
      );

      await _supabase
          .from('salary_settings')
          .upsert(defaultSettings.toJson());

      settings.value = defaultSettings;
      print('Default salary settings initialized successfully');
    } catch (e) {
      print('Error initializing default salary settings: $e');
      error.value = e.toString();
    }
  }

  // Charger les paramètres depuis Supabase
  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      error.value = '';

      final farmerId = _authService.currentUser?.id.toString();
      if (farmerId == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final response = await _supabase
          .from('salary_settings')
          .select()
          .eq('farmer_id', farmerId)
          .single();

      if (response != null) {
        settings.value = SalarySettingsModel.fromJson(response);
      } else {
        // Si aucun paramètre n'existe, initialiser les valeurs par défaut
        await initializeDefaultSettings();
      }
    } catch (e) {
      print('Error loading salary settings: $e');
      // Si aucun paramètre n'existe, initialiser les valeurs par défaut
      await initializeDefaultSettings();
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour les paramètres
  Future<void> updateSettings(SalarySettingsModel newSettings) async {
    try {
      isLoading.value = true;
      error.value = '';

      final farmerId = _authService.currentUser?.id;
      print('Current user ID: $farmerId');

      if (farmerId == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // S'assurer que le farmerId est défini
      final settingsWithFarmerId = newSettings.copyWith(
        farmerId: farmerId,
      );

      print('Updating settings with: ${settingsWithFarmerId.toJson()}');

      // Vérifier si des paramètres existent déjà pour ce fermier
      final existing = await _supabase
          .from('salary_settings')
          .select()
          .eq('farmer_id', farmerId)
          .maybeSingle();

      if (existing != null) {
        // Mise à jour des paramètres existants
        final response = await _supabase
            .from('salary_settings')
            .update(settingsWithFarmerId.toJson())
            .eq('farmer_id', farmerId)
            .select()
            .single();
        print('Update response: $response');
        settings.value = SalarySettingsModel.fromJson(response);
      } else {
        // Création de nouveaux paramètres
        final response = await _supabase
            .from('salary_settings')
            .insert(settingsWithFarmerId.toJson())
            .select()
            .single();
        print('Insert response: $response');
        settings.value = SalarySettingsModel.fromJson(response);
      }

      // Fermer le dialogue des paramètres avant d'afficher le snackbar
      Get.back();

      // Attendre un peu avant d'afficher le snackbar
      await Future.delayed(const Duration(milliseconds: 100));
      
      Get.snackbar(
        'Succès',
        'Les paramètres de rémunération ont été mis à jour avec succès',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

    } catch (e) {
      print('Error updating salary settings: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour les paramètres: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Valider les paramètres
  String? validateSettings(SalarySettingsModel settings) {
    if (settings.maxTotalBonus < 0 || settings.maxTotalBonus > 1) {
      return 'Le bonus maximum doit être entre 0% et 100%';
    }
    if (settings.onTimeCompletionBonus < 0 || settings.onTimeCompletionBonus > settings.maxTotalBonus) {
      return 'Le bonus de complétion doit être entre 0% et le bonus maximum';
    }
    if (settings.highProductivityBonus < 0 || settings.highProductivityBonus > settings.maxTotalBonus) {
      return 'Le bonus de productivité doit être entre 0% et le bonus maximum';
    }
    if (settings.overdueTaskPenalty < 0 || settings.overdueTaskPenalty > 1) {
      return 'Le malus par tâche en retard doit être entre 0% et 100%';
    }
    return null;
  }
} 