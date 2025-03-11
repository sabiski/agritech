import 'package:get/get.dart';
import '../controllers/report_controller.dart';
import '../../finance/controllers/finance_controller.dart';
import '../../employee/controllers/employee_controller.dart';
import '../../stock/controllers/stock_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportController>(
      () => ReportController(),
    );
    Get.lazyPut<FinanceController>(
      () => FinanceController(),
    );
    Get.lazyPut<EmployeeController>(
      () => EmployeeController(),
    );
    Get.lazyPut<StockController>(
      () => StockController(),
    );
  }
} 