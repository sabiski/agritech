import 'package:get/get.dart';
import '../controllers/marketplace_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketplaceController>(
      () => MarketplaceController(),
    );
  }
} 