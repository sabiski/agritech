import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../../services/auth_service.dart';

class FarmerDashboardView extends StatefulWidget {
  const FarmerDashboardView({super.key});

  @override
  State<FarmerDashboardView> createState() => _FarmerDashboardViewState();
}

class _FarmerDashboardViewState extends State<FarmerDashboardView> {
  final _authService = Get.find<AuthService>();
  final _themeController = Get.find<ThemeController>();
  int _selectedIndex = 0;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.userMetadata?['full_name'] as String? ?? 'Utilisateur';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobileLayout();
          }
          return _buildDesktopLayout();
        },
      ),
    );
  }

  Widget _buildDrawer() {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 32,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _userName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            selected: _selectedIndex == 0,
            selectedColor: AppTheme.primaryGreen,
            leading: const Icon(Icons.dashboard_outlined),
            title: Text(
              'Tableau de bord',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: _selectedIndex == 1,
            selectedColor: AppTheme.primaryGreen,
            leading: const Icon(Icons.agriculture_outlined),
            title: Text(
              'Cultures',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
              Get.toNamed('/crops');
            },
          ),
          ListTile(
            selected: _selectedIndex == 2,
            selectedColor: AppTheme.primaryGreen,
            leading: const Icon(Icons.inventory_outlined),
            title: Text(
              'Stock',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
              Get.toNamed('/stock');
            },
          ),
          ListTile(
            selected: _selectedIndex == 3,
            selectedColor: AppTheme.primaryGreen,
            leading: const Icon(Icons.attach_money_outlined),
            title: Text(
              'Finances',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              setState(() => _selectedIndex = 3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: _selectedIndex == 4,
            selectedColor: AppTheme.primaryGreen,
            leading: const Icon(Icons.people_outline),
            title: Text(
              'Employés',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              setState(() => _selectedIndex = 4);
              Navigator.pop(context);
            },
          ),
          ListTile(
            selected: _selectedIndex == 5,
            selectedColor: AppTheme.primaryGreen,
            leading: const Icon(Icons.analytics_outlined),
            title: Text(
              'Rapports',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              setState(() => _selectedIndex = 5);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: Row(
              children: [
                Text(
                  'Marketplace',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              // TODO: Vérifier si l'utilisateur est premium
              Get.snackbar(
                'Fonctionnalité Premium',
                'Cette fonctionnalité est réservée aux utilisateurs premium.',
                backgroundColor: Colors.amber,
                colorText: Colors.black87,
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: Row(
              children: [
                Text(
                  'Formations',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              // TODO: Vérifier si l'utilisateur est premium
              Get.snackbar(
                'Fonctionnalité Premium',
                'Cette fonctionnalité est réservée aux utilisateurs premium.',
                backgroundColor: Colors.amber,
                colorText: Colors.black87,
              );
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(
              'Profil',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              // TODO: Navigation vers le profil
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(
              'Paramètres',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              // TODO: Navigation vers les paramètres
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              'Déconnexion',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () async {
              await _authService.signOut();
              Get.offAllNamed('/auth');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Tableau de bord',
            style: theme.appBarTheme.titleTextStyle,
          ),
          actions: [
            Obx(() => IconButton(
              icon: Icon(
                _themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: theme.colorScheme.onBackground,
              ),
              onPressed: () => _themeController.toggleTheme(),
            )),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $_userName',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildWeatherCard(),
                const SizedBox(height: 24),
                // Statistiques
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      title: 'Cultures actives',
                      value: '12',
                      icon: Icons.agriculture,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      title: 'Stock',
                      value: '85%',
                      icon: Icons.inventory,
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      title: 'Revenus',
                      value: '2.5M FCFA',
                      icon: Icons.attach_money,
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      title: 'Employés',
                      value: '8',
                      icon: Icons.people,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Graphique des revenus
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenus mensuels',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin'];
                                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                                      return Text(
                                        months[value.toInt()],
                                        style: theme.textTheme.bodySmall,
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 1.5),
                                  FlSpot(1, 2.0),
                                  FlSpot(2, 1.8),
                                  FlSpot(3, 2.5),
                                  FlSpot(4, 2.2),
                                  FlSpot(5, 3.0),
                                ],
                                isCurved: true,
                                color: AppTheme.primaryGreen,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppTheme.primaryGreen.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Tâches et alertes
                Row(
                  children: [
                    Expanded(
                      child: _buildTasksCard(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAlertsCard(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Menu latéral (existant)
        NavigationRail(
          extended: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
            switch (index) {
              case 0:
                // Tableau de bord - reste sur la page actuelle
                break;
              case 1:
                Get.toNamed('/crops');
                break;
              case 2:
                Get.toNamed('/stock');
                break;
              // Autres cas à implémenter pour les autres sections
            }
          },
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'AgriGestion',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _userName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Tableau de bord'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.agriculture_outlined),
              selectedIcon: Icon(Icons.agriculture),
              label: Text('Cultures'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.inventory_outlined),
              selectedIcon: Icon(Icons.inventory),
              label: Text('Stock'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.attach_money_outlined),
              selectedIcon: Icon(Icons.attach_money),
              label: Text('Finances'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: Text('Employés'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: Text('Rapports'),
            ),
          ],
        ),

        // Contenu principal (existant)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              children: [
                // Barre supérieure (existante)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Bonjour, $_userName 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Obx(() => IconButton(
                        onPressed: _themeController.toggleTheme,
                        icon: Icon(
                          _themeController.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        tooltip: 'Changer le thème',
                      )),
                      const SizedBox(width: 8),
                      PopupMenuButton(
                        child: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen,
                          child: Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('Profil'),
                              onTap: () {
                                // TODO: Navigation vers le profil
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.settings),
                              title: const Text('Paramètres'),
                              onTap: () {
                                // TODO: Navigation vers les paramètres
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.logout),
                              title: const Text('Déconnexion'),
                              onTap: () async {
                                await _authService.signOut();
                                Get.offAllNamed('/auth');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Contenu du tableau de bord (existant)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildStatCard(
                              title: 'Cultures actives',
                              value: '12',
                              icon: Icons.agriculture,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              title: 'Stock disponible',
                              value: '2.5 tonnes',
                              icon: Icons.inventory,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              title: 'Revenus du mois',
                              value: '1.2M FCFA',
                              icon: Icons.attach_money,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 300,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Revenus mensuels',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
                                            if (value.toInt() < months.length) {
                                              return Text(months[value.toInt()]);
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: const [
                                          FlSpot(0, 1.2),
                                          FlSpot(1, 1.8),
                                          FlSpot(2, 1.5),
                                          FlSpot(3, 2.2),
                                          FlSpot(4, 1.9),
                                          FlSpot(5, 2.5),
                                        ],
                                        isCurved: true,
                                        color: AppTheme.primaryGreen,
                                        barWidth: 3,
                                        dotData: FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: AppTheme.primaryGreen.withOpacity(0.1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTasksList(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildAlertsList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksCard() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tâches à faire',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSimpleTaskItem('Arroser les tomates', '09:00', true),
          _buildSimpleTaskItem('Vérifier les stocks', '11:00', false),
          _buildSimpleTaskItem('Réunion employés', '14:00', false),
        ],
      ),
    );
  }

  Widget _buildSimpleTaskItem(String task, String time, bool isDone) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? AppTheme.primaryGreen : theme.textTheme.bodySmall?.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task,
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? theme.textTheme.bodySmall?.color : null,
              ),
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tâches à faire',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailedTaskItem(
            'Arroser les tomates',
            'Aujourd\'hui',
            Colors.orange,
          ),
          _buildDetailedTaskItem(
            'Récolter les carottes',
            'Demain',
            Colors.green,
          ),
          _buildDetailedTaskItem(
            'Commander des semences',
            'Cette semaine',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTaskItem(String title, String deadline, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  deadline,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              // TODO: Marquer comme terminé
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alertes',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAlertItem(
            'Niveau d\'eau bas',
            'Parcelle de tomates',
            Colors.red,
          ),
          _buildAlertItem(
            'Stock faible',
            'Engrais NPK',
            Colors.orange,
          ),
          _buildAlertItem(
            'Prévision de pluie',
            'Demain',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: color,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alertes',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildAlertItem(
            'Stock faible en engrais',
            'Il reste moins de 20% du stock',
            Colors.orange,
          ),
          _buildAlertItem(
            'Maintenance du tracteur',
            'Prévue dans 3 jours',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Météo',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Libreville, Gabon',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const Icon(
                Icons.wb_sunny,
                color: Colors.orange,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherInfo(
                icon: Icons.thermostat_outlined,
                value: '28°C',
                label: 'Température',
              ),
              _buildWeatherInfo(
                icon: Icons.water_drop_outlined,
                value: '75%',
                label: 'Humidité',
              ),
              _buildWeatherInfo(
                icon: Icons.air_outlined,
                value: '12 km/h',
                label: 'Vent',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Prévisions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildForecastItem('Lun', '29°C', Icons.wb_sunny),
                _buildForecastItem('Mar', '27°C', Icons.cloud),
                _buildForecastItem('Mer', '28°C', Icons.wb_sunny),
                _buildForecastItem('Jeu', '26°C', Icons.thunderstorm),
                _buildForecastItem('Ven', '28°C', Icons.wb_sunny),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo({
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildForecastItem(String day, String temp, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            temp,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 