import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/salary_settings_model.dart';

class SalarySettingsService extends GetxService {
  final _supabase = Supabase.instance.client;
  final Rx<SalarySettingsModel> settings = SalarySettingsModel().obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Charger les paramètres depuis Supabase
  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _supabase
          .from('salary_settings')
          .select()
          .single();

      if (response != null) {
        settings.value = SalarySettingsModel.fromJson(response);
      }
    } catch (e) {
      print('Error loading salary settings: $e');
      // Si aucun paramètre n'existe, utiliser les valeurs par défaut
      settings.value = SalarySettingsModel();
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour les paramètres
  Future<void> updateSettings(SalarySettingsModel newSettings) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _supabase
          .from('salary_settings')
          .upsert(newSettings.toJson());

      settings.value = newSettings;
      Get.snackbar(
        'Succès',
        'Paramètres de rémunération mis à jour',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Error updating salary settings: $e');
      error.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour les paramètres',
        snackPosition: SnackPosition.TOP,
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