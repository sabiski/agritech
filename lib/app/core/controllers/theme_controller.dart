import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  final _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromBox();
    _loadThemeMode();
  }

  void _loadThemeFromBox() {
    _isDarkMode.value = _box.read(_key) ?? false;
  }

  void _saveThemeToBox(bool isDarkMode) {
    _box.write(_key, isDarkMode);
  }

  void _loadThemeMode() {
    final isDarkMode = _box.read(_key);
    if (isDarkMode != null) {
      _isDarkMode.value = isDarkMode;
      _themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void _updateTheme() {
    Get.changeTheme(_isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme);
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _themeMode.value = _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
    _saveThemeToBox(_isDarkMode.value);
    _updateTheme();
  }
} 