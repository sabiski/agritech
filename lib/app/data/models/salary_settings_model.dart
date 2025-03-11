class SalarySettingsModel {
  final double onTimeCompletionBonus; // Bonus pour complétion dans les délais (%)
  final double highProductivityBonus; // Bonus pour haute productivité (%)
  final double overdueTaskPenalty; // Malus par tâche en retard (%)
  final double maxTotalBonus; // Bonus maximum total (%)
  final int productivityTaskThreshold; // Nombre de tâches pour bonus productivité
  final int productivityCompletionThreshold; // Nombre min. de tâches complétées pour bonus
  final double excellentPerformanceRate; // Taux pour bonus maximum (90% = 0.9)
  final double goodPerformanceRate; // Taux pour bonus standard (80% = 0.8)

  SalarySettingsModel({
    this.onTimeCompletionBonus = 0.10, // 10% par défaut
    this.highProductivityBonus = 0.05, // 5% par défaut
    this.overdueTaskPenalty = 0.02, // 2% par défaut
    this.maxTotalBonus = 0.25, // 25% par défaut
    this.productivityTaskThreshold = 10,
    this.productivityCompletionThreshold = 8,
    this.excellentPerformanceRate = 0.9,
    this.goodPerformanceRate = 0.8,
  });

  // Convertir en Map pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'on_time_completion_bonus': onTimeCompletionBonus,
      'high_productivity_bonus': highProductivityBonus,
      'overdue_task_penalty': overdueTaskPenalty,
      'max_total_bonus': maxTotalBonus,
      'productivity_task_threshold': productivityTaskThreshold,
      'productivity_completion_threshold': productivityCompletionThreshold,
      'excellent_performance_rate': excellentPerformanceRate,
      'good_performance_rate': goodPerformanceRate,
    };
  }

  // Créer une instance à partir d'un Map
  factory SalarySettingsModel.fromJson(Map<String, dynamic> json) {
    return SalarySettingsModel(
      onTimeCompletionBonus: (json['on_time_completion_bonus'] as num).toDouble(),
      highProductivityBonus: (json['high_productivity_bonus'] as num).toDouble(),
      overdueTaskPenalty: (json['overdue_task_penalty'] as num).toDouble(),
      maxTotalBonus: (json['max_total_bonus'] as num).toDouble(),
      productivityTaskThreshold: json['productivity_task_threshold'] as int,
      productivityCompletionThreshold: json['productivity_completion_threshold'] as int,
      excellentPerformanceRate: (json['excellent_performance_rate'] as num).toDouble(),
      goodPerformanceRate: (json['good_performance_rate'] as num).toDouble(),
    );
  }

  // Copier l'instance avec des modifications
  SalarySettingsModel copyWith({
    double? onTimeCompletionBonus,
    double? highProductivityBonus,
    double? overdueTaskPenalty,
    double? maxTotalBonus,
    int? productivityTaskThreshold,
    int? productivityCompletionThreshold,
    double? excellentPerformanceRate,
    double? goodPerformanceRate,
  }) {
    return SalarySettingsModel(
      onTimeCompletionBonus: onTimeCompletionBonus ?? this.onTimeCompletionBonus,
      highProductivityBonus: highProductivityBonus ?? this.highProductivityBonus,
      overdueTaskPenalty: overdueTaskPenalty ?? this.overdueTaskPenalty,
      maxTotalBonus: maxTotalBonus ?? this.maxTotalBonus,
      productivityTaskThreshold: productivityTaskThreshold ?? this.productivityTaskThreshold,
      productivityCompletionThreshold: productivityCompletionThreshold ?? this.productivityCompletionThreshold,
      excellentPerformanceRate: excellentPerformanceRate ?? this.excellentPerformanceRate,
      goodPerformanceRate: goodPerformanceRate ?? this.goodPerformanceRate,
    );
  }
} 