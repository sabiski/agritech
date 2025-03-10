import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color bgColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.bgColor,
  });
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isDarkMode = false;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Bienvenue sur AgriGestion',
      description: 'La solution complète pour révolutionner l\'agriculture au Gabon. Connectons les agriculteurs aux opportunités.',
      icon: Icons.waving_hand,
      bgColor: const Color(0xFF3ECF8E).withOpacity(0.2),
    ),
    OnboardingItem(
      title: 'Agriculture Intelligente',
      description: 'Utilisez des outils modernes pour optimiser vos cultures, suivre votre production et maximiser vos rendements.',
      icon: Icons.agriculture,
      bgColor: const Color(0xFF6C63FF).withOpacity(0.2),
    ),
    OnboardingItem(
      title: 'Marché Direct',
      description: 'Vendez directement aux consommateurs. Éliminez les intermédiaires et obtenez de meilleurs prix pour vos produits.',
      icon: Icons.store,
      bgColor: const Color(0xFFFF6B6B).withOpacity(0.2),
    ),
    OnboardingItem(
      title: 'Conseils Experts',
      description: 'Accédez à des conseils personnalisés, des formations et un support technique pour améliorer vos pratiques agricoles.',
      icon: Icons.school,
      bgColor: const Color(0xFFFFBE0B).withOpacity(0.2),
    ),
    OnboardingItem(
      title: 'Communauté Agricole',
      description: 'Rejoignez une communauté dynamique d\'agriculteurs, partagez vos expériences et grandissez ensemble.',
      icon: Icons.people,
      bgColor: const Color(0xFF4CAF50).withOpacity(0.2),
    ),
    OnboardingItem(
      title: 'Traçabilité Complète',
      description: 'Garantissez la qualité de vos produits aux consommateurs grâce à une traçabilité transparente de la ferme à l\'assiette.',
      icon: Icons.track_changes,
      bgColor: const Color(0xFF00BCD4).withOpacity(0.2),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    Navigator.of(context).pushReplacementNamed(Routes.AUTH);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header with theme toggle
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo and title
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primaryGreen,
                                    AppTheme.secondaryGreen,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.eco,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    AppTheme.primaryGreen,
                                    AppTheme.secondaryGreen,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'AgriGestion',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Theme toggle
                      Material(
                        borderRadius: BorderRadius.circular(16),
                        elevation: 4,
                        color: Theme.of(context).colorScheme.surface,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _toggleTheme,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: AppTheme.primaryGreen,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final item = _pages[index];
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 32),
                              // Icon container with gradient border
                              Container(
                                padding: const EdgeInsets.all(32),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      item.bgColor,
                                      item.bgColor.withOpacity(0.5),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppTheme.primaryGreen.withOpacity(0.2),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: item.bgColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 120,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),

                              const SizedBox(height: 48),
                              
                              // Title with gradient
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    AppTheme.primaryGreen,
                                    AppTheme.secondaryGreen,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  item.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Description
                              Text(
                                item.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom navigation
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'Passer',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80),

                      // Page indicator
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _pages.length,
                        effect: WormEffect(
                          dotHeight: 10,
                          dotWidth: 10,
                          spacing: 8,
                          dotColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white24
                              : Colors.black12,
                          activeDotColor: AppTheme.primaryGreen,
                        ),
                      ),

                      // Next/Start button
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1
                                  ? 'Commencer'
                                  : 'Suivant',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage == _pages.length - 1
                                  ? Icons.login
                                  : Icons.arrow_forward,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 