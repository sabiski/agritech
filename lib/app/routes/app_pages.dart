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
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.FARMER,
      page: () => const FarmerView(),
      binding: FarmerBinding(),
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
      name: Routes.FARMER_DASHBOARD,
      page: () => const FarmerDashboardView(),
      binding: FarmerBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.SUPPLIER_DASHBOARD,
      page: () => const SupplierDashboardView(),
      binding: SupplierBinding(),
    ),
    GetPage(
      name: Routes.CUSTOMER_DASHBOARD,
      page: () => const CustomerDashboardView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: Routes.DELIVERY_DASHBOARD,
      page: () => const DeliveryDashboardView(),
      binding: DeliveryBinding(),
    ),
    GetPage(
      name: Routes.CROPS,
      page: () => const CropsView(),
      binding: CropsBinding(),
    ),
  ];
} 