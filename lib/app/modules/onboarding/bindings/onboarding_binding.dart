import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import '../../../core/controllers/theme_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
    Get.lazyPut<ThemeController>(() => ThemeController());
  }
} 