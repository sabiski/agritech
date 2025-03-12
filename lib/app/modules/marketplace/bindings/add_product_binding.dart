import 'package:get/get.dart';
import '../controllers/marketplace_controller.dart';

class AddProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketplaceController>(
      () => MarketplaceController(),
    );
  }
} 