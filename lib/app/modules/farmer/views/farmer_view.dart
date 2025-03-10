import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/farmer_controller.dart';
import 'farmer_dashboard_view.dart';

class FarmerView extends GetView<FarmerController> {
  const FarmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return const FarmerDashboardView();
  }
} 