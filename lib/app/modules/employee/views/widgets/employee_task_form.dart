import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/employee_controller.dart';
import '../../../../data/models/employee_task_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class EmployeeTaskForm extends StatefulWidget {
  final String employeeId;
  final EmployeeTaskModel? task;

  const EmployeeTaskForm({
    super.key,
    required this.employeeId,
    this.task,
  });

  @override
  State<EmployeeTaskForm> createState() => _EmployeeTaskFormState();
}

class _EmployeeTaskFormState extends State<EmployeeTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<EmployeeController>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskPriority _priority;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _priority = widget.task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        if (widget.task != null) {
          final updatedTask = EmployeeTaskModel(
            id: widget.task!.id,
            title: _titleController.text,
            description: _descriptionController.text,
            dueDate: _dueDate,
            status: widget.task!.status,
            priority: _priority,
            employeeId: widget.employeeId,
            completedAt: widget.task!.completedAt,
            createdAt: widget.task!.createdAt,
            updatedAt: DateTime.now(),
          );
          await _controller.updateTask(updatedTask);
        } else {
          await _controller.addTask(
            title: _titleController.text,
            description: _descriptionController.text,
            dueDate: _dueDate,
            priority: _priority,
            employeeId: widget.employeeId,
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
            widget.task != null ? 'Modifier la tâche' : 'Ajouter une tâche',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          
          // Titre
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un titre';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          // Date d'échéance
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date d\'échéance',
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Priorité
          DropdownButtonFormField<TaskPriority>(
            value: _priority,
            decoration: const InputDecoration(
              labelText: 'Priorité',
              border: OutlineInputBorder(),
            ),
            items: TaskPriority.values.map((priority) {
              String label;
              Color color;
              
              switch (priority) {
                case TaskPriority.low:
                  label = 'Basse';
                  color = Colors.green;
                  break;
                case TaskPriority.medium:
                  label = 'Moyenne';
                  color = Colors.orange;
                  break;
                case TaskPriority.high:
                  label = 'Haute';
                  color = Colors.red;
                  break;
              }
              
              return DropdownMenuItem(
                value: priority,
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
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _priority = value);
              }
            },
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
                        widget.task != null ? 'Modifier' : 'Ajouter',
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