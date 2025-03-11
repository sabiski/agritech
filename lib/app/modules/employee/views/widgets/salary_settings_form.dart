import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../services/salary_settings_service.dart';
import '../../../../data/models/salary_settings_model.dart';

class SalarySettingsForm extends StatefulWidget {
  const SalarySettingsForm({super.key});

  @override
  State<SalarySettingsForm> createState() => _SalarySettingsFormState();
}

class _SalarySettingsFormState extends State<SalarySettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final _settingsService = Get.find<SalarySettingsService>();

  late TextEditingController _onTimeCompletionBonusController;
  late TextEditingController _highProductivityBonusController;
  late TextEditingController _overdueTaskPenaltyController;
  late TextEditingController _maxTotalBonusController;
  late TextEditingController _productivityTaskThresholdController;
  late TextEditingController _productivityCompletionThresholdController;
  late TextEditingController _excellentPerformanceRateController;
  late TextEditingController _goodPerformanceRateController;

  @override
  void initState() {
    super.initState();
    final settings = _settingsService.settings.value;
    _onTimeCompletionBonusController = TextEditingController(
      text: (settings.onTimeCompletionBonus * 100).toString(),
    );
    _highProductivityBonusController = TextEditingController(
      text: (settings.highProductivityBonus * 100).toString(),
    );
    _overdueTaskPenaltyController = TextEditingController(
      text: (settings.overdueTaskPenalty * 100).toString(),
    );
    _maxTotalBonusController = TextEditingController(
      text: (settings.maxTotalBonus * 100).toString(),
    );
    _productivityTaskThresholdController = TextEditingController(
      text: settings.productivityTaskThreshold.toString(),
    );
    _productivityCompletionThresholdController = TextEditingController(
      text: settings.productivityCompletionThreshold.toString(),
    );
    _excellentPerformanceRateController = TextEditingController(
      text: (settings.excellentPerformanceRate * 100).toString(),
    );
    _goodPerformanceRateController = TextEditingController(
      text: (settings.goodPerformanceRate * 100).toString(),
    );
  }

  @override
  void dispose() {
    _onTimeCompletionBonusController.dispose();
    _highProductivityBonusController.dispose();
    _overdueTaskPenaltyController.dispose();
    _maxTotalBonusController.dispose();
    _productivityTaskThresholdController.dispose();
    _productivityCompletionThresholdController.dispose();
    _excellentPerformanceRateController.dispose();
    _goodPerformanceRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres de rémunération',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          
          // Bonus maximum total
          _buildPercentageField(
            controller: _maxTotalBonusController,
            label: 'Bonus maximum total',
            hint: 'Ex: 25 pour 25%',
            helperText: 'Le pourcentage maximum de bonus qu\'un employé peut recevoir',
          ),
          const SizedBox(height: 16),

          // Bonus pour complétion dans les délais
          _buildPercentageField(
            controller: _onTimeCompletionBonusController,
            label: 'Bonus pour complétion dans les délais',
            hint: 'Ex: 10 pour 10%',
            helperText: 'Le bonus accordé pour avoir complété les tâches à temps',
          ),
          const SizedBox(height: 16),

          // Bonus pour haute productivité
          _buildPercentageField(
            controller: _highProductivityBonusController,
            label: 'Bonus pour haute productivité',
            hint: 'Ex: 5 pour 5%',
            helperText: 'Le bonus accordé pour une productivité élevée',
          ),
          const SizedBox(height: 16),

          // Malus par tâche en retard
          _buildPercentageField(
            controller: _overdueTaskPenaltyController,
            label: 'Malus par tâche en retard',
            hint: 'Ex: 2 pour 2%',
            helperText: 'Le pourcentage de malus appliqué pour chaque tâche en retard',
          ),
          const SizedBox(height: 24),

          Text(
            'Seuils de performance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Nombre de tâches pour bonus productivité
          _buildNumberField(
            controller: _productivityTaskThresholdController,
            label: 'Seuil de tâches pour bonus productivité',
            hint: 'Ex: 10',
            helperText: 'Nombre minimum de tâches pour être éligible au bonus de productivité',
          ),
          const SizedBox(height: 16),

          // Nombre minimum de tâches complétées
          _buildNumberField(
            controller: _productivityCompletionThresholdController,
            label: 'Seuil de tâches complétées',
            hint: 'Ex: 8',
            helperText: 'Nombre minimum de tâches complétées pour le bonus',
          ),
          const SizedBox(height: 24),

          Text(
            'Taux de performance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Taux pour performance excellente
          _buildPercentageField(
            controller: _excellentPerformanceRateController,
            label: 'Taux pour performance excellente',
            hint: 'Ex: 90 pour 90%',
            helperText: 'Taux de complétion pour obtenir le bonus maximum',
          ),
          const SizedBox(height: 16),

          // Taux pour bonne performance
          _buildPercentageField(
            controller: _goodPerformanceRateController,
            label: 'Taux pour bonne performance',
            hint: 'Ex: 80 pour 80%',
            helperText: 'Taux de complétion pour obtenir le bonus standard',
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: _settingsService.isLoading.value
                  ? null
                  : _saveSettings,
              child: _settingsService.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer les paramètres'),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String helperText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        suffixText: '%',
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        final number = double.tryParse(value);
        if (number == null) {
          return 'Veuillez entrer un nombre valide';
        }
        if (number < 0 || number > 100) {
          return 'Le pourcentage doit être entre 0 et 100';
        }
        return null;
      },
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String helperText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        final number = int.tryParse(value);
        if (number == null) {
          return 'Veuillez entrer un nombre valide';
        }
        if (number < 0) {
          return 'Le nombre doit être positif';
        }
        return null;
      },
    );
  }

  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      final newSettings = SalarySettingsModel(
        onTimeCompletionBonus: double.parse(_onTimeCompletionBonusController.text) / 100,
        highProductivityBonus: double.parse(_highProductivityBonusController.text) / 100,
        overdueTaskPenalty: double.parse(_overdueTaskPenaltyController.text) / 100,
        maxTotalBonus: double.parse(_maxTotalBonusController.text) / 100,
        productivityTaskThreshold: int.parse(_productivityTaskThresholdController.text),
        productivityCompletionThreshold: int.parse(_productivityCompletionThresholdController.text),
        excellentPerformanceRate: double.parse(_excellentPerformanceRateController.text) / 100,
        goodPerformanceRate: double.parse(_goodPerformanceRateController.text) / 100,
      );

      final validationError = _settingsService.validateSettings(newSettings);
      if (validationError != null) {
        Get.snackbar(
          'Erreur de validation',
          validationError,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      _settingsService.updateSettings(newSettings);
    }
  }
} 