import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/employee_controller.dart';
import '../../../../data/models/employee_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class EmployeeForm extends StatefulWidget {
  final EmployeeModel? employee;

  const EmployeeForm({
    super.key,
    this.employee,
  });

  @override
  State<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<EmployeeController>();
  final _scrollController = ScrollController();
  
  late TextEditingController _fullNameController;
  late TextEditingController _positionController;
  late TextEditingController _salaryController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late DateTime _startDate;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.employee?.fullName ?? '');
    _positionController = TextEditingController(text: widget.employee?.position ?? '');
    _salaryController = TextEditingController(text: widget.employee?.salary.toString() ?? '');
    _phoneController = TextEditingController(text: widget.employee?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _addressController = TextEditingController(text: widget.employee?.address ?? '');
    _notesController = TextEditingController(text: widget.employee?.notes ?? '');
    _startDate = widget.employee?.startDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        if (widget.employee != null) {
          final updatedEmployee = EmployeeModel(
            id: widget.employee!.id,
            fullName: _fullNameController.text,
            position: _positionController.text,
            salary: double.parse(_salaryController.text),
            phoneNumber: _phoneController.text,
            email: _emailController.text,
            status: widget.employee!.status,
            startDate: _startDate,
            endDate: widget.employee!.endDate,
            address: _addressController.text,
            notes: _notesController.text,
            createdAt: widget.employee!.createdAt,
            updatedAt: DateTime.now(),
            farmerId: widget.employee!.farmerId,
          );
          await _controller.updateEmployee(updatedEmployee);
        } else {
          await _controller.addEmployee(
            fullName: _fullNameController.text,
            position: _positionController.text,
            salary: double.parse(_salaryController.text),
            phoneNumber: _phoneController.text,
            email: _emailController.text,
            startDate: _startDate,
            address: _addressController.text,
            notes: _notesController.text,
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.employee != null ? 'Modifier l\'employé' : 'Ajouter un employé',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nom complet
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom complet';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Poste
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      labelText: 'Poste',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le poste';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Salaire
                  TextFormField(
                    controller: _salaryController,
                    decoration: const InputDecoration(
                      labelText: 'Salaire',
                      border: OutlineInputBorder(),
                      prefixText: 'FCFA ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le salaire';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Téléphone
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le numéro de téléphone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date de début
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de début',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Adresse
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Boutons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Annuler'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.employee != null ? 'Modifier' : 'Ajouter',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 