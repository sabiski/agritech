import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class CustomerDashboardView extends StatelessWidget {
  const CustomerDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tableau de bord Client',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Tableau de bord en construction...',
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 