import 'package:get/get.dart';
import '../controllers/marketplace_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketplaceController>(
      () => MarketplaceController(),
    );
  }
} 