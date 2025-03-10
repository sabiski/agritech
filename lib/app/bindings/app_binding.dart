import 'package:get/get.dart';
import '../core/controllers/theme_controller.dart';
import '../services/auth_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService());
    Get.put(ThemeController());
  }
} 