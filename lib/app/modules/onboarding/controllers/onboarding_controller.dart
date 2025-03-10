import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  final _prefs = SharedPreferences.getInstance();
  final _key = 'hasSeenOnboarding';

  final List<OnboardingItem> pages = [
    OnboardingItem(
      title: 'Bienvenue sur AgriGestion',
      description: 'La solution complète pour révolutionner l\'agriculture au Gabon. Connectons les agriculteurs aux opportunités.',
      lottieAsset: 'assets/lottie/welcome_farming.json',
      bgColor: const Color(0xFF3ECF8E).withOpacity(0.2),
    ),
    OnboardingItem(
      title: 'Agriculture Intelligente',
      description: 'Utilisez des outils modernes pour optimiser vos cultures, suivre votre production et maximiser vos rendements.',
      lottieAsset: 'assets/lottie/smart_farming.json',
      bgColor: const Color(0xFF6C63FF).withOpacity(0.2),
    ),
    OnboardingItem(
      title: 'Marché Direct',
      description: 'Vendez directement aux consommateurs. Éliminez les intermédiaires et obtenez de meilleurs prix pour vos produits.',
      lottieAsset: 'assets/lottie/marketplace.json',
      bgColor: const Color(0xFFFF6B6B).withOpacity(0.2),
    ),
    OnboardingItem(
      title: 'Conseils Experts',
      description: 'Accédez à des conseils personnalisés, des formations et un support technique pour améliorer vos pratiques agricoles.',
      lottieAsset: 'assets/lottie/expert_advice.json',
      bgColor: const Color(0xFFFFBE0B).withOpacity(0.2),
    ),
    OnboardingItem(
      title: 'Communauté Agricole',
      description: 'Rejoignez une communauté dynamique d\'agriculteurs, partagez vos expériences et grandissez ensemble.',
      lottieAsset: 'assets/lottie/community.json',
      bgColor: const Color(0xFF4CAF50).withOpacity(0.2),
    ),
    OnboardingItem(
      title: 'Traçabilité Complète',
      description: 'Garantissez la qualité de vos produits aux consommateurs grâce à une traçabilité transparente de la ferme à l\'assiette.',
      lottieAsset: 'assets/lottie/traceability.json',
      bgColor: const Color(0xFF00BCD4).withOpacity(0.2),
    ),
  ];

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  Future<void> completeOnboarding() async {
    final prefs = await _prefs;
    await prefs.setBool(_key, true);
    Get.offAllNamed('/auth');
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await _prefs;
    return prefs.getBool(_key) ?? false;
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String lottieAsset;
  final Color bgColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.bgColor,
  });
} 