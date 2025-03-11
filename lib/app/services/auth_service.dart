import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_pages.dart';

class AuthService extends GetxService {
  final supabase = Supabase.instance.client;

  Future<AuthService> init() async {
    return this;
  }

  User? get currentUser => supabase.auth.currentUser;

  // Connexion
  Future<String> signIn(String email, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        final role = res.user!.userMetadata?['role'] as String?;
        if (role == null) {
          throw 'Rôle utilisateur non défini';
        }
        return role;
      } else {
        throw 'Email ou mot de passe incorrect';
      }
    } catch (e) {
      throw 'Erreur: ${e.toString()}';
    }
  }

  // Inscription
  Future<String> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phoneNumber,
    String? address,
    String? businessName,
    String? businessType,
  }) async {
    try {
      print('Tentative d\'inscription avec les données suivantes :');
      print('Email: $email');
      print('Nom complet: $fullName');
      print('Rôle: $role');
      print('Téléphone: $phoneNumber');
      print('Adresse: $address');
      print('Nom de l\'entreprise: $businessName');
      print('Type d\'entreprise: $businessType');

      final userMetadata = {
        'full_name': fullName,
        'role': role,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (address != null) 'address': address,
        if (businessName != null) 'business_name': businessName,
        if (businessType != null) 'business_type': businessType,
      };

      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: userMetadata,
      );

      if (res.user == null) {
        throw Exception('L\'inscription a échoué : utilisateur null');
      }

      print('Inscription réussie ! ID utilisateur : ${res.user!.id}');
      return role;
    } catch (e) {
      print('Erreur lors de l\'inscription : $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Récupération du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw 'Erreur: ${e.toString()}';
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool isAuthenticated() {
    return supabase.auth.currentUser != null;
  }

  // Récupérer le rôle de l'utilisateur connecté
  Future<String?> getCurrentUserRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      
      return profile['role'] as String;
    } catch (e) {
      return null;
    }
  }

  // Rediriger vers la page appropriée selon le rôle
  void redirectBasedOnRole(BuildContext context, String role) {
    switch (role) {
      case 'farmer':
        Navigator.pushReplacementNamed(context, Routes.FARMER_DASHBOARD);
        break;
      case 'supplier':
        Navigator.pushReplacementNamed(context, Routes.SUPPLIER_DASHBOARD);
        break;
      case 'customer':
        Navigator.pushReplacementNamed(context, Routes.CUSTOMER_DASHBOARD);
        break;
      case 'delivery':
        Navigator.pushReplacementNamed(context, Routes.DELIVERY_DASHBOARD);
        break;
      default:
        throw 'Rôle non reconnu: $role';
    }
  }
} 