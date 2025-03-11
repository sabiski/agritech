import 'package:get/get.dart';
import '../controllers/employee_controller.dart';
import '../services/employee_analytics_service.dart';
import '../services/salary_settings_service.dart';
import '../services/salary_service.dart';
import '../../finance/controllers/finance_controller.dart';

class EmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinanceController>(
      () => FinanceController(),
    );
    Get.lazyPut<EmployeeController>(
      () => EmployeeController(),
    );
    Get.lazyPut<EmployeeAnalyticsService>(
      () => EmployeeAnalyticsService(),
    );
    Get.lazyPut<SalarySettingsService>(
      () => SalarySettingsService(),
    );
    Get.lazyPut<SalaryService>(
      () => SalaryService(),
    );
  }
} 