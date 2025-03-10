import 'package:get/get.dart';
import '../controllers/farmer_controller.dart';

class FarmerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerController>(
      () => FarmerController(),
    );
  }
} 