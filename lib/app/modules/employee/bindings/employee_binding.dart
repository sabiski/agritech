import 'package:get/get.dart';
import '../controllers/employee_controller.dart';
import '../services/employee_analytics_service.dart';

class EmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeController>(
      () => EmployeeController(),
    );
    Get.lazyPut<EmployeeAnalyticsService>(
      () => EmployeeAnalyticsService(),
    );
  }
} 