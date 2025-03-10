import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  final isLoading = false.obs;
  final isAuthenticated = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }
  
  Future<void> checkAuth() async {
    final session = _supabase.auth.currentSession;
    isAuthenticated.value = session != null;
  }
  
  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      isAuthenticated.value = true;
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la connexion: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      Get.snackbar(
        'Succès',
        'Inscription réussie. Veuillez vérifier votre email.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'inscription: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      isAuthenticated.value = false;
      Get.offAllNamed('/auth');
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la déconnexion: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 