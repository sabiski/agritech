import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/salary_settings_service.dart';
import '../../../../data/models/salary_settings_model.dart';

class SalarySettingsForm extends StatefulWidget {
  const SalarySettingsForm({super.key});

  @override
  State<SalarySettingsForm> createState() => _SalarySettingsFormState();
}

class _SalarySettingsFormState extends State<SalarySettingsForm> {
  final _settingsService = Get.find<SalarySettingsService>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _excellentPerformanceController;
  late TextEditingController _goodPerformanceController;
  late TextEditingController _onTimeCompletionBonusController;
  late TextEditingController _overdueTaskPenaltyController;
  late TextEditingController _productivityTaskThresholdController;
  late TextEditingController _productivityCompletionThresholdController;
  late TextEditingController _highProductivityBonusController;
  late TextEditingController _maxTotalBonusController;

  @override
  void initState() {
    super.initState();
    final settings = _settingsService.settings.value;
    _excellentPerformanceController = TextEditingController(
      text: (settings.excellentPerformanceRate * 100).toString(),
    );
    _goodPerformanceController = TextEditingController(
      text: (settings.goodPerformanceRate * 100).toString(),
    );
    _onTimeCompletionBonusController = TextEditingController(
      text: (settings.onTimeCompletionBonus * 100).toString(),
    );
    _overdueTaskPenaltyController = TextEditingController(
      text: (settings.overdueTaskPenalty * 100).toString(),
    );
    _productivityTaskThresholdController = TextEditingController(
      text: settings.productivityTaskThreshold.toString(),
    );
    _productivityCompletionThresholdController = TextEditingController(
      text: settings.productivityCompletionThreshold.toString(),
    );
    _highProductivityBonusController = TextEditingController(
      text: (settings.highProductivityBonus * 100).toString(),
    );
    _maxTotalBonusController = TextEditingController(
      text: (settings.maxTotalBonus * 100).toString(),
    );
  }

  @override
  void dispose() {
    _excellentPerformanceController.dispose();
    _goodPerformanceController.dispose();
    _onTimeCompletionBonusController.dispose();
    _overdueTaskPenaltyController.dispose();
    _productivityTaskThresholdController.dispose();
    _productivityCompletionThresholdController.dispose();
    _highProductivityBonusController.dispose();
    _maxTotalBonusController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final newSettings = SalarySettingsModel(
        excellentPerformanceRate: double.parse(_excellentPerformanceController.text) / 100,
        goodPerformanceRate: double.parse(_goodPerformanceController.text) / 100,
        onTimeCompletionBonus: double.parse(_onTimeCompletionBonusController.text) / 100,
        overdueTaskPenalty: double.parse(_overdueTaskPenaltyController.text) / 100,
        productivityTaskThreshold: int.parse(_productivityTaskThresholdController.text),
        productivityCompletionThreshold: int.parse(_productivityCompletionThresholdController.text),
        highProductivityBonus: double.parse(_highProductivityBonusController.text) / 100,
        maxTotalBonus: double.parse(_maxTotalBonusController.text) / 100,
      );

      await _settingsService.updateSettings(newSettings);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Paramètres de rémunération',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),

                // Taux de performance
                _buildSection(
                  title: 'Taux de performance',
                  children: [
                    _buildPercentageField(
                      controller: _excellentPerformanceController,
                      label: 'Performance excellente',
                      hint: 'Ex: 90%',
                    ),
                    const SizedBox(height: 16),
                    _buildPercentageField(
                      controller: _goodPerformanceController,
                      label: 'Bonne performance',
                      hint: 'Ex: 70%',
                    ),
                  ],
                ),

                // Bonus et pénalités
                _buildSection(
                  title: 'Bonus et pénalités',
                  children: [
                    _buildPercentageField(
                      controller: _onTimeCompletionBonusController,
                      label: 'Bonus tâches à temps',
                      hint: 'Ex: 10%',
                    ),
                    const SizedBox(height: 16),
                    _buildPercentageField(
                      controller: _overdueTaskPenaltyController,
                      label: 'Pénalité tâches en retard',
                      hint: 'Ex: 5%',
                    ),
                  ],
                ),

                // Seuils de productivité
                _buildSection(
                  title: 'Seuils de productivité',
                  children: [
                    _buildNumberField(
                      controller: _productivityTaskThresholdController,
                      label: 'Nombre de tâches minimum',
                      hint: 'Ex: 10',
                    ),
                    const SizedBox(height: 16),
                    _buildNumberField(
                      controller: _productivityCompletionThresholdController,
                      label: 'Tâches complétées minimum',
                      hint: 'Ex: 8',
                    ),
                  ],
                ),

                // Bonus maximum
                _buildSection(
                  title: 'Bonus maximum',
                  children: [
                    _buildPercentageField(
                      controller: _highProductivityBonusController,
                      label: 'Bonus haute productivité',
                      hint: 'Ex: 15%',
                    ),
                    const SizedBox(height: 16),
                    _buildPercentageField(
                      controller: _maxTotalBonusController,
                      label: 'Bonus total maximum',
                      hint: 'Ex: 30%',
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPercentageField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixText: '%',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        final number = int.tryParse(value);
        if (number == null) {
          return 'Veuillez entrer un nombre entier';
        }
        if (number < 0) {
          return 'Le nombre doit être positif';
        }
        return null;
      },
    );
  }
} 