import 'package:get/get.dart';
import '../controllers/finance_controller.dart';
import '../../employee/controllers/employee_controller.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinanceController>(
      () => FinanceController(),
    );
    Get.lazyPut<EmployeeController>(
      () => EmployeeController(),
    );
  }
} 