import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/crop_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controllers/crops_controller.dart';

class CropDetailsDialog extends StatelessWidget {
  final CropModel crop;

  const CropDetailsDialog({
    super.key,
    required this.crop,
  });

  Future<void> _showDiagnosticDialog(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Diagnostic de culture',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Prenez ou choisissez une photo de votre culture pour analyse',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              if (!GetPlatform.isWeb)
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      final XFile? photo = await picker.pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 80,
                                        maxWidth: 1920,
                                        maxHeight: 1080,
                                      );
                                      if (photo != null && context.mounted) {
                                        await _analyzeImage(photo);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('La caméra n\'est pas disponible sur ce dispositif'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Prendre une photo'),
                                ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 80,
                                      maxWidth: 1920,
                                      maxHeight: 1080,
                                    );
                                    if (image != null && context.mounted) {
                                      await _analyzeImage(image);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Impossible de charger l\'image'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Choisir une photo'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _analyzeImage(XFile image) async {
    try {
      Get.back();
      final bytes = await image.readAsBytes();
      
      await showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: Get.width * 0.9,
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: Get.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Analyse de l\'image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                bytes,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Informations
                            const Text(
                              'Diagnostic préliminaire',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildAnalysisItem(
                                      icon: Icons.local_florist,
                                      title: 'Culture identifiée',
                                      content: crop.name,
                                    ),
                                    const Divider(),
                                    _buildAnalysisItem(
                                      icon: Icons.health_and_safety,
                                      title: 'État de santé',
                                      content: 'Analyse en attente',
                                      isWarning: true,
                                    ),
                                    const Divider(),
                                    _buildAnalysisItem(
                                      icon: Icons.bug_report,
                                      title: 'Risques détectés',
                                      content: 'Aucun risque détecté pour le moment',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Recommandations
                            const Text(
                              'Recommandations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.tips_and_updates, color: Colors.amber),
                                      title: const Text('Conseil 1'),
                                      subtitle: const Text('Surveillez régulièrement l\'état des feuilles'),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.water_drop, color: Colors.blue),
                                      title: const Text('Conseil 2'),
                                      subtitle: Text('Maintenez une irrigation adaptée : ${crop.waterNeeds}'),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.schedule, color: Colors.green),
                                      title: const Text('Conseil 3'),
                                      subtitle: const Text('Effectuez des inspections hebdomadaires'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey, width: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Fermer'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            Get.snackbar(
                              'Information',
                              'L\'analyse détaillée par IA sera bientôt disponible',
                              backgroundColor: Colors.blue,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 5),
                            );
                          },
                          icon: const Icon(Icons.analytics),
                          label: const Text('Analyse détaillée'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'analyser l\'image : ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildAnalysisItem({
    required IconData icon,
    required String title,
    required String content,
    bool isWarning = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isWarning ? Colors.orange : AppTheme.primaryGreen,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  color: isWarning ? Colors.orange : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CropsController>();
    final isWide = MediaQuery.of(context).size.width > 600;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isWide ? Get.width * 0.8 : Get.width * 0.95,
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      crop.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Confirmer la suppression'),
                          content: Text('Voulez-vous vraiment supprimer la culture "${crop.name}" ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await controller.deleteCrop(crop.id);
                                  Get.back();
                                  Get.back();
                                  Get.snackbar(
                                    'Succès',
                                    'Culture supprimée avec succès',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } catch (e) {
                                  Get.back();
                                  Get.snackbar(
                                    'Erreur',
                                    'Impossible de supprimer la culture',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: !isWide,
                      labelStyle: const TextStyle(fontSize: 13),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.info_outline, size: 20),
                          text: 'Guide',
                        ),
                        Tab(
                          icon: Icon(Icons.calendar_today, size: 20),
                          text: 'Calendrier',
                        ),
                        Tab(
                          icon: Icon(Icons.healing, size: 20),
                          text: 'Santé',
                        ),
                        Tab(
                          icon: Icon(Icons.analytics, size: 20),
                          text: 'Rendement',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildGuideTab(context),
                          _buildCalendrierTab(context),
                          _buildSanteTab(context),
                          _buildRendementTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showDiagnosticDialog(context),
                icon: const Icon(Icons.camera_alt, size: 20),
                label: const Text('Diagnostic par photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guide de plantation
          _buildGuideSectionWithExpansion(
            context,
            title: 'Comment planter',
            icon: Icons.agriculture,
            mainContent: [
              'Sol idéal : ${crop.soilType.isEmpty ? 'À compléter par un expert' : crop.soilType}',
              'Espacement recommandé : ${crop.spacing.isEmpty ? 'À compléter par un expert' : crop.spacing}',
              'Méthode de plantation : ${crop.plantingMethod}',
            ],
            expandableTitle: 'Conseils supplémentaires pour la plantation',
            expandableContent: [
              '• Préparez bien le sol avant la plantation',
              '• Vérifiez que le drainage est bon',
              '• Choisissez la bonne période de plantation',
              '• Suivez l\'espacement recommandé',
            ],
          ),
          const SizedBox(height: 16),

          // Besoins de la plante
          _buildGuideSectionWithExpansion(
            context,
            title: 'Besoins de la plante',
            icon: Icons.water_drop,
            mainContent: [
              'Eau : ${crop.waterNeeds.isEmpty ? 'À compléter par un expert' : crop.waterNeeds}',
              'Climat : ${crop.climate.isEmpty ? 'À compléter par un expert' : crop.climate}',
              'Température : ${crop.temperature.isEmpty ? 'À compléter par un expert' : crop.temperature}',
            ],
            expandableTitle: 'Signes de manque d\'eau',
            expandableContent: [
              '• Feuilles qui flétrissent',
              '• Sol sec en profondeur',
              '• Croissance ralentie',
              '• Jaunissement des feuilles',
            ],
          ),
          const SizedBox(height: 16),

          // Entretien quotidien
          _buildGuideSectionWithExpansion(
            context,
            title: 'Entretien quotidien',
            icon: Icons.schedule,
            mainContent: crop.maintenance.split('\n'),
            expandableTitle: 'Calendrier d\'entretien recommandé',
            expandableContent: [
              '• Désherbage : Toutes les 2 semaines',
              '• Inspection des plants : Quotidienne',
              '• Fertilisation : Selon les besoins',
              '• Taille : Quand nécessaire',
            ],
          ),
          const SizedBox(height: 16),

          // Récolte
          _buildGuideSectionWithExpansion(
            context,
            title: 'Récolte',
            icon: Icons.agriculture,
            mainContent: [
              'Période de récolte : ${crop.harvestPeriod}',
              'Rendement moyen : ${crop.averageYield} tonnes/ha',
              'Prix moyen : ${crop.averagePrice} FCFA/kg',
            ],
            expandableTitle: 'Signes de maturité',
            expandableContent: [
              '• Couleur caractéristique',
              '• Taille optimale atteinte',
              '• Texture appropriée',
              '• Période de croissance complétée',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSectionWithExpansion(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> mainContent,
    required String expandableTitle,
    required List<String> expandableContent,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...mainContent.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
            Theme(
              data: ThemeData(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  expandableTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                children: expandableContent.map((item) => ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                  title: Text(
                    item,
                    style: const TextStyle(fontSize: 13),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendrierTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTimelineItem(
            context,
            phase: 'Préparation',
            duration: 'Avant plantation',
            tasks: [
              'Préparer le sol',
              'Vérifier la qualité du sol',
              'Préparer les outils',
            ],
          ),
          _buildTimelineItem(
            context,
            phase: 'Plantation',
            duration: 'Jour J',
            tasks: [
              crop.plantingMethod,
              'Respecter l\'espacement de ${crop.spacing}',
              'Arroser abondamment',
            ],
          ),
          _buildTimelineItem(
            context,
            phase: 'Croissance',
            duration: crop.growthCycle,
            tasks: [
              'Surveiller l\'arrosage',
              'Désherber régulièrement',
              'Observer la santé des plants',
            ],
          ),
          _buildTimelineItem(
            context,
            phase: 'Récolte',
            duration: crop.harvestPeriod,
            tasks: [
              'Vérifier la maturité',
              'Récolter avec soin',
              'Stocker correctement',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSanteTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHealthSection(
            context,
            title: 'Signes de bonne santé',
            icon: Icons.check_circle,
            content: [
              'Feuilles vertes et fermes',
              'Croissance régulière',
              'Pas de taches suspectes',
            ],
          ),
          const SizedBox(height: 16),
          _buildHealthSection(
            context,
            title: 'Attention aux parasites',
            icon: Icons.bug_report,
            content: crop.pests.split('\n'),
          ),
          const SizedBox(height: 16),
          _buildHealthSection(
            context,
            title: 'Maladies courantes',
            icon: Icons.healing,
            content: crop.diseases.split('\n'),
          ),
          const SizedBox(height: 16),
          _buildHealthSection(
            context,
            title: 'Solutions naturelles',
            icon: Icons.eco,
            content: [
              'Rotation des cultures',
              'Associations bénéfiques',
              'Préparations traditionnelles',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRendementTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRendementSection(
            context,
            title: 'Rendement attendu',
            content: '${crop.averageYield} tonnes par hectare',
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 16),
          _buildRendementSection(
            context,
            title: 'Prix moyen',
            content: '${crop.averagePrice} FCFA par kg',
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 16),
          _buildRendementSection(
            context,
            title: 'Exemple de revenu',
            content: 'Pour 1 hectare :\n${(crop.averageYield * 1000 * crop.averagePrice).toStringAsFixed(0)} FCFA',
            icon: Icons.calculate,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String phase,
    required String duration,
    required List<String> tasks,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    phase,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '($duration)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...tasks.map((task) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(task)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...content.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fiber_manual_record, size: 12),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRendementSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 