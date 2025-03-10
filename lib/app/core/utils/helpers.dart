import 'package:get/get.dart';
import 'package:flutter/material.dart';

void showSuccessSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
    snackPosition: SnackPosition.TOP,
  );
}

void showErrorSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    backgroundColor: Colors.red,
    colorText: Colors.white,
    duration: const Duration(seconds: 5),
    snackPosition: SnackPosition.TOP,
  );
}

void showInfoSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    backgroundColor: Colors.blue,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
    snackPosition: SnackPosition.TOP,
  );
}

void showWarningSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    backgroundColor: Colors.orange,
    colorText: Colors.white,
    duration: const Duration(seconds: 4),
    snackPosition: SnackPosition.TOP,
  );
}

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String formatCurrency(double amount) {
  return '${amount.toStringAsFixed(0)} FCFA';
}

String formatQuantity(double quantity, String unit) {
  return '${quantity.toStringAsFixed(1)} $unit';
}

// Fonction pour calculer le nombre de jours restants
String getRemainingDays(DateTime date) {
  final difference = date.difference(DateTime.now()).inDays;
  if (difference < 0) {
    return 'Expiré';
  } else if (difference == 0) {
    return 'Expire aujourd\'hui';
  } else if (difference == 1) {
    return 'Expire demain';
  } else {
    return 'Expire dans $difference jours';
  }
} 