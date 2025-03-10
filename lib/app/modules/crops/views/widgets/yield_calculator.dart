import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../data/models/crop_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controllers/crops_controller.dart';

class YieldCalculatorDialog extends StatefulWidget {
  const YieldCalculatorDialog({super.key});

  @override
  State<YieldCalculatorDialog> createState() => _YieldCalculatorDialogState();
}

class _YieldCalculatorDialogState extends State<YieldCalculatorDialog> {
  final _controller = Get.find<CropsController>();
  
  CropModel? _selectedCrop;
  double _area = 1.0;
  double _efficiency = 1.0;
  double _priceMultiplier = 1.0;
  
  double? _yield;
  double? _revenue;
  
  void _calculate() {
    if (_selectedCrop == null) return;
    
    setState(() {
      _yield = _controller.calculateYield(
        _selectedCrop!,
        _area,
      );
      
      _revenue = _controller.calculateRevenue(
        _selectedCrop!,
        _yield!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              'Calculateur de Rendement',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Sélection de la culture
            DropdownButtonFormField<CropModel>(
              value: _selectedCrop,
              decoration: const InputDecoration(
                labelText: 'Culture',
                border: OutlineInputBorder(),
              ),
              items: _controller.filteredCrops.map((crop) {
                return DropdownMenuItem(
                  value: crop,
                  child: Text(crop.name),
                );
              }).toList(),
              onChanged: (crop) {
                setState(() {
                  _selectedCrop = crop;
                  _yield = null;
                  _revenue = null;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Surface en hectares
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Surface (hectares)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              initialValue: _area.toString(),
              onChanged: (value) {
                setState(() {
                  _area = double.tryParse(value) ?? 1.0;
                  _yield = null;
                  _revenue = null;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Bouton calculer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedCrop == null ? null : _calculate,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('Calculer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Résultats
            if (_yield != null && _revenue != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résultats',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildResultRow(
                      context,
                      label: 'Rendement estimé',
                      value: '${_yield!.toStringAsFixed(1)} tonnes',
                    ),
                    const SizedBox(height: 8),
                    _buildResultRow(
                      context,
                      label: 'Revenu potentiel',
                      value: '${_revenue!.toStringAsFixed(0)} FCFA',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 