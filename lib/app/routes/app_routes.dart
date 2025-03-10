part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const AUTH = _Paths.AUTH;
  static const FARMER = _Paths.FARMER;
  static const STOCK = _Paths.STOCK;
  static const FINANCE = _Paths.FINANCE;
  static const FARMER_DASHBOARD = '/farmer';
  static const SUPPLIER_DASHBOARD = '/supplier';
  static const CUSTOMER_DASHBOARD = '/customer';
  static const DELIVERY_DASHBOARD = '/delivery';
  static const CROPS = '/crops';
}

abstract class _Paths {
  static const HOME = '/home';
  static const ONBOARDING = '/onboarding';
  static const AUTH = '/auth';
  static const FARMER = '/farmer';
  static const STOCK = '/stock';
  static const FINANCE = '/finance';
} 