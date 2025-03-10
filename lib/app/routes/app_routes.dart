part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const AUTH = _Paths.AUTH;
  static const FARMER = _Paths.FARMER;
  static const STOCK = _Paths.STOCK;
  static const FINANCE = _Paths.FINANCE;
  static const FARMER_DASHBOARD = _Paths.FARMER + _Paths.DASHBOARD;
  static const SUPPLIER = _Paths.SUPPLIER;
  static const SUPPLIER_DASHBOARD = _Paths.SUPPLIER + _Paths.DASHBOARD;
  static const CUSTOMER = _Paths.CUSTOMER;
  static const CUSTOMER_DASHBOARD = _Paths.CUSTOMER + _Paths.DASHBOARD;
  static const DELIVERY = _Paths.DELIVERY;
  static const DELIVERY_DASHBOARD = _Paths.DELIVERY + _Paths.DASHBOARD;
  static const CROPS = _Paths.CROPS;
  static const EMPLOYEE = _Paths.EMPLOYEE;
}

abstract class _Paths {
  _Paths._();

  static const HOME = '/';
  static const ONBOARDING = '/onboarding';
  static const AUTH = '/auth';
  static const FARMER = '/farmer';
  static const DASHBOARD = '/dashboard';
  static const SUPPLIER = '/supplier';
  static const CUSTOMER = '/customer';
  static const DELIVERY = '/delivery';
  static const CROPS = '/crops';
  static const STOCK = '/stock';
  static const FINANCE = '/finance';
  static const EMPLOYEE = '/employee';
} 