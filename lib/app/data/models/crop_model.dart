import 'package:get/get.dart';

enum CropCategory {
  all,
  foodCrops,
  marketGardens,
  fruitTrees,
  industrialCrops,
  fodderCrops
}

enum GrowthStage {
  semis,
  croissance,
  floraison,
  recolte
}

class CropModel {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String origin;
  final String imageUrl;
  final CropCategory category;
  final String soilType;
  final String waterNeeds;
  final String climate;
  final String temperature;
  final String plantingMethod;
  final String spacing;
  final String growthCycle;
  final String maintenance;
  final String pests;
  final String diseases;
  final String harvestPeriod;
  final double averageYield;
  final double averagePrice;
  final RxBool isFavorite;
  final RxInt viewCount;

  CropModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.origin,
    required this.imageUrl,
    required this.category,
    required this.soilType,
    required this.waterNeeds,
    required this.climate,
    required this.temperature,
    required this.plantingMethod,
    required this.spacing,
    required this.growthCycle,
    required this.maintenance,
    required this.pests,
    required this.diseases,
    required this.harvestPeriod,
    required this.averageYield,
    required this.averagePrice,
    bool isFavorite = false,
    int viewCount = 0,
  })  : isFavorite = isFavorite.obs,
        viewCount = viewCount.obs;

  // Créer une copie de l'objet avec des valeurs modifiées
  CropModel copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? description,
    String? origin,
    String? imageUrl,
    CropCategory? category,
    String? soilType,
    String? waterNeeds,
    String? climate,
    String? temperature,
    String? plantingMethod,
    String? spacing,
    String? growthCycle,
    String? maintenance,
    String? pests,
    String? diseases,
    String? harvestPeriod,
    double? averageYield,
    double? averagePrice,
    bool? isFavorite,
    int? viewCount,
  }) {
    return CropModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
      origin: origin ?? this.origin,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      soilType: soilType ?? this.soilType,
      waterNeeds: waterNeeds ?? this.waterNeeds,
      climate: climate ?? this.climate,
      temperature: temperature ?? this.temperature,
      plantingMethod: plantingMethod ?? this.plantingMethod,
      spacing: spacing ?? this.spacing,
      growthCycle: growthCycle ?? this.growthCycle,
      maintenance: maintenance ?? this.maintenance,
      pests: pests ?? this.pests,
      diseases: diseases ?? this.diseases,
      harvestPeriod: harvestPeriod ?? this.harvestPeriod,
      averageYield: averageYield ?? this.averageYield,
      averagePrice: averagePrice ?? this.averagePrice,
      isFavorite: isFavorite ?? this.isFavorite.value,
      viewCount: viewCount ?? this.viewCount.value,
    );
  }

  // Convertir l'objet en Map pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'description': description,
      'origin': origin,
      'image_url': imageUrl,
      'category': category.toString().split('.').last,
      'soil_type': soilType,
      'water_needs': waterNeeds,
      'climate': climate,
      'temperature': temperature,
      'planting_method': plantingMethod,
      'spacing': spacing,
      'growth_cycle': growthCycle,
      'maintenance': maintenance,
      'pests': pests,
      'diseases': diseases,
      'harvest_period': harvestPeriod,
      'average_yield': averageYield,
      'average_price': averagePrice,
      'is_favorite': isFavorite.value,
      'view_count': viewCount.value,
    };
  }

  // Créer un objet à partir d'une Map de Supabase
  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientific_name'] as String,
      description: json['description'] as String,
      origin: json['origin'] as String,
      imageUrl: json['image_url'] as String,
      category: CropCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => CropCategory.foodCrops,
      ),
      soilType: json['soil_type'] as String,
      waterNeeds: json['water_needs'] as String,
      climate: json['climate'] as String,
      temperature: json['temperature'] as String,
      plantingMethod: json['planting_method'] as String,
      spacing: json['spacing'] as String,
      growthCycle: json['growth_cycle'] as String,
      maintenance: json['maintenance'] as String,
      pests: json['pests'] as String,
      diseases: json['diseases'] as String,
      harvestPeriod: json['harvest_period'] as String,
      averageYield: (json['average_yield'] as num).toDouble(),
      averagePrice: (json['average_price'] as num).toDouble(),
      isFavorite: json['is_favorite'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
    );
  }

  // Exemple de culture pour les tests
  static CropModel maniocExample() {
    return CropModel(
      id: '1',
      name: 'Manioc',
      scientificName: 'Manihot esculenta',
      description: 'Le manioc est une plante vivace à tubercules comestibles.',
      origin: 'Amérique du Sud',
      imageUrl: 'assets/images/manioc.jpg',
      category: CropCategory.foodCrops,
      soilType: 'Sol sableux à argileux, bien drainé',
      waterNeeds: 'Modérés',
      climate: 'Tropical',
      temperature: '25-29°C',
      plantingMethod: 'Boutures de tiges',
      spacing: '1m x 1m',
      growthCycle: '8-12 mois',
      maintenance: 'Désherbage régulier',
      pests: 'Cochenilles, acariens',
      diseases: 'Mosaïque du manioc',
      harvestPeriod: '8-12 mois après plantation',
      averageYield: 10.0,
      averagePrice: 200.0,
    );
  }
} 