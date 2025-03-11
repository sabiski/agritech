import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/farmer/bindings/farmer_binding.dart';
import '../modules/farmer/views/farmer_view.dart';
import '../modules/farmer/views/farmer_dashboard_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/stock/bindings/stock_binding.dart';
import '../modules/stock/views/stock_view.dart';
import '../modules/supplier/bindings/supplier_binding.dart';
import '../modules/supplier/views/supplier_dashboard_view.dart';
import '../modules/customer/bindings/customer_binding.dart';
import '../modules/customer/views/customer_dashboard_view.dart';
import '../modules/delivery/bindings/delivery_binding.dart';
import '../modules/delivery/views/delivery_dashboard_view.dart';
import '../modules/crops/bindings/crops_binding.dart';
import '../modules/crops/views/crops_view.dart';
import '../modules/finance/bindings/finance_binding.dart';
import '../modules/finance/views/finance_view.dart';
import '../modules/employee/bindings/employee_binding.dart';
import '../modules/employee/views/employee_view.dart';
import '../modules/report/bindings/report_binding.dart';
import '../modules/report/views/report_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.FARMER,
      page: () => const FarmerView(),
      binding: FarmerBinding(),
    ),
    GetPage(
      name: _Paths.FARMER_DASHBOARD,
      page: () => const FarmerDashboardView(),
      binding: FarmerBinding(),
    ),
    GetPage(
      name: _Paths.SUPPLIER,
      page: () => const SupplierDashboardView(),
      binding: SupplierBinding(),
      children: [
        GetPage(
          name: _Paths.DASHBOARD,
          page: () => const SupplierDashboardView(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.CUSTOMER,
      page: () => const CustomerDashboardView(),
      binding: CustomerBinding(),
      children: [
        GetPage(
          name: _Paths.DASHBOARD,
          page: () => const CustomerDashboardView(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.DELIVERY,
      page: () => const DeliveryDashboardView(),
      binding: DeliveryBinding(),
      children: [
        GetPage(
          name: _Paths.DASHBOARD,
          page: () => const DeliveryDashboardView(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.CROPS,
      page: () => const CropsView(),
      binding: CropsBinding(),
    ),
    GetPage(
      name: _Paths.STOCK,
      page: () => const StockView(),
      binding: StockBinding(),
    ),
    GetPage(
      name: _Paths.FINANCE,
      page: () => const FinanceView(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.EMPLOYEE,
      page: () => const EmployeeView(),
      binding: EmployeeBinding(),
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () => const ReportView(),
      binding: ReportBinding(),
    ),
  ];
} 