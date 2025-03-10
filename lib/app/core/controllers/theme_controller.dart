import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromBox();
    _updateTheme();
  }

  void _loadThemeFromBox() {
    _isDarkMode.value = _box.read(_key) ?? false;
  }

  void _saveThemeToBox(bool isDarkMode) {
    _box.write(_key, isDarkMode);
  }

  void _updateTheme() {
    Get.changeTheme(_isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme);
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _saveThemeToBox(_isDarkMode.value);
    _updateTheme();
  }
} 