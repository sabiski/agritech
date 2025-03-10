import 'package:get/get.dart';
import '../controllers/crops_controller.dart';
import '../../../services/crop_service.dart';

class CropsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CropService>(() => CropService());
    Get.lazyPut<CropsController>(() => CropsController());
  }
} 