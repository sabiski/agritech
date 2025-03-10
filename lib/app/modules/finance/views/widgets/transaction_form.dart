import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/finance_controller.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionForm extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionForm({
    super.key,
    this.transaction,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<FinanceController>();
  final _supabase = Supabase.instance.client;
  
  late TextEditingController _categoryController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _date;
  late TransactionType _type;
  bool _isLoading = false;
  
  final List<String> _predefinedCategories = [
    'Vente de produits',
    'Achat de semences',
    'Achat d\'engrais',
    'Salaires',
    'Équipement',
    'Transport',
    'Maintenance',
    'Autre',
  ];
  
  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.transaction?.category ?? '');
    _amountController = TextEditingController(text: widget.transaction?.amount.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.transaction?.description ?? '');
    _date = widget.transaction?.date ?? DateTime.now();
    _type = widget.transaction?.type ?? TransactionType.income;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.transaction == null ? 'Nouvelle transaction' : 'Modifier la transaction',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            // Type de transaction
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Revenu'),
                    value: TransactionType.income,
                    groupValue: _type,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _type = value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Dépense'),
                    value: TransactionType.expense,
                    groupValue: _type,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _type = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Catégorie
            DropdownButtonFormField<String>(
              value: _categoryController.text.isEmpty ? null : _categoryController.text,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
              ),
              items: _predefinedCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _categoryController.text = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner une catégorie';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Montant
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                labelText: 'Montant (FCFA)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un montant';
                }
                if (double.tryParse(value) == null) {
                  return 'Montant invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _date = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd/MM/yyyy').format(_date)),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optionnelle)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Get.back(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(widget.transaction == null ? 'Ajouter' : 'Modifier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final transaction = TransactionModel(
          id: widget.transaction?.id ?? const Uuid().v4(),
          type: _type,
          category: _categoryController.text,
          amount: double.parse(_amountController.text),
          date: _date,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          createdAt: widget.transaction?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          farmerId: _supabase.auth.currentUser!.id,
        );

        if (widget.transaction == null) {
          await _controller.addTransaction(transaction);
        } else {
          await _controller.updateTransaction(transaction);
        }
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Une erreur est survenue: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
} 