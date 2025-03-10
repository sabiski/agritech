import 'package:get/get.dart';
import 'crop_model.dart';

enum PlantationStatus {
  planification,
  preparation,
  plantation,
  croissance,
  recolte,
  termine
}

class PlantationModel {
  final String id;
  final String userId;
  final CropModel crop;
  final String name;
  final String description;
  final double surface;
  final DateTime datePlantation;
  final DateTime? dateRecolteEstimee;
  final RxDouble progression;
  final RxString status;
  final List<String> notes;
  final Map<DateTime, String> journal;
  final Map<String, dynamic> parametres;

  PlantationModel({
    required this.id,
    required this.userId,
    required this.crop,
    required this.name,
    required this.description,
    required this.surface,
    required this.datePlantation,
    this.dateRecolteEstimee,
    double progression = 0.0,
    String status = 'planification',
    this.notes = const [],
    this.journal = const {},
    this.parametres = const {},
  })  : progression = progression.obs,
        status = status.obs;

  // Convertir en Map pour Supabase
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'crop_id': crop.id,
    'name': name,
    'description': description,
    'surface': surface,
    'date_plantation': datePlantation.toIso8601String(),
    'date_recolte_estimee': dateRecolteEstimee?.toIso8601String(),
    'progression': progression.value,
    'status': status.value,
    'notes': notes,
    'journal': journal.map((key, value) => MapEntry(key.toIso8601String(), value)),
    'parametres': parametres,
  };

  // Créer depuis Map de Supabase
  static Future<PlantationModel> fromJson(Map<String, dynamic> json, CropModel crop) async {
    return PlantationModel(
      id: json['id'],
      userId: json['user_id'],
      crop: crop,
      name: json['name'],
      description: json['description'],
      surface: json['surface'],
      datePlantation: DateTime.parse(json['date_plantation']),
      dateRecolteEstimee: json['date_recolte_estimee'] != null
          ? DateTime.parse(json['date_recolte_estimee'])
          : null,
      progression: json['progression'],
      status: json['status'],
      notes: List<String>.from(json['notes']),
      journal: (json['journal'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(DateTime.parse(key), value as String),
      ),
      parametres: json['parametres'],
    );
  }

  // Calculer le rendement estimé
  double get rendementEstime => surface * crop.averageYield;

  // Calculer le revenu potentiel
  double get revenuPotentiel => rendementEstime * crop.averagePrice;

  // Obtenir les prochaines tâches
  List<String> get prochainesTaches {
    switch (status.value) {
      case 'planification':
        return [
          'Préparer le terrain',
          'Acheter les semences',
          'Vérifier les outils',
        ];
      case 'preparation':
        return [
          'Labourer le sol',
          'Ajouter les fertilisants',
          'Préparer l\'irrigation',
        ];
      case 'plantation':
        return [
          'Planter les semences',
          'Mettre en place le système d\'irrigation',
          'Installer les protections',
        ];
      case 'croissance':
        return [
          'Surveiller la croissance',
          'Contrôler les maladies',
          'Gérer l\'irrigation',
        ];
      case 'recolte':
        return [
          'Organiser l\'équipe de récolte',
          'Préparer le stockage',
          'Planifier la vente',
        ];
      default:
        return [];
    }
  }

  // Obtenir les conseils selon le stade
  List<String> get conseilsActuels {
    switch (status.value) {
      case 'planification':
        return [
          'Étudiez bien le calendrier cultural',
          'Vérifiez la qualité du sol',
          'Prévoyez un plan d\'irrigation',
        ];
      case 'preparation':
        return [
          'Préparez le sol selon les recommandations',
          'Suivez les recommandations de fertilisation',
          'Préparez un système de drainage adéquat',
        ];
      case 'plantation':
        return [
          crop.plantingMethod,
          'Respectez l\'espacement de ${crop.spacing}',
          'Arrosez abondamment après la plantation',
        ];
      case 'croissance':
        return [
          'Suivez le plan de maintenance : ${crop.maintenance}',
          'Surveillez les parasites : ${crop.pests}',
          'Surveillez les maladies : ${crop.diseases}',
        ];
      case 'recolte':
        return [
          'Récoltez pendant ${crop.harvestPeriod}',
          'Stockez correctement la récolte',
          'Surveillez les prix du marché',
        ];
      default:
        return [];
    }
  }
} 