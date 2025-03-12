part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const AUTH = _Paths.AUTH;
  static const FARMER = _Paths.FARMER;
  static const STOCK = _Paths.STOCK;
  static const FINANCE = _Paths.FINANCE;
  static const FARMER_DASHBOARD = _Paths.FARMER_DASHBOARD;
  static const SUPPLIER = _Paths.SUPPLIER;
  static const SUPPLIER_DASHBOARD = '/supplier/dashboard';
  static const CUSTOMER = _Paths.CUSTOMER;
  static const CUSTOMER_DASHBOARD = '/customer/dashboard';
  static const DELIVERY = _Paths.DELIVERY;
  static const DELIVERY_DASHBOARD = '/delivery/dashboard';
  static const CROPS = _Paths.CROPS;
  static const EMPLOYEE = _Paths.EMPLOYEE;
  static const EMPLOYEE_DETAIL = _Paths.EMPLOYEE_DETAIL;
  static const REPORT = _Paths.REPORT;
  static const MARKETPLACE = _Paths.MARKETPLACE;
  static const ADD_PRODUCT = _Paths.MARKETPLACE + _Paths.ADD_PRODUCT;
  static const CART = _Paths.MARKETPLACE + _Paths.CART;
  static const ORDERS = _Paths.MARKETPLACE + _Paths.ORDERS;
}

abstract class _Paths {
  _Paths._();

  static const HOME = '/home';
  static const ONBOARDING = '/onboarding';
  static const AUTH = '/auth';
  static const FARMER = '/farmer';
  static const FARMER_DASHBOARD = '/farmer-dashboard';
  static const DASHBOARD = '/dashboard';
  static const SUPPLIER = '/supplier';
  static const CUSTOMER = '/customer';
  static const DELIVERY = '/delivery';
  static const CROPS = '/crops';
  static const STOCK = '/stock';
  static const FINANCE = '/finance';
  static const EMPLOYEE = '/employee';
  static const EMPLOYEE_DETAIL = '/employee/detail';
  static const REPORT = '/report';
  static const MARKETPLACE = '/marketplace';
  static const ADD_PRODUCT = '/add-product';
  static const CART = '/cart';
  static const ORDERS = '/orders';
} 