import 'package:flutter/material.dart';
import '../models/maintenance_record.dart';
import '../models/maintenance_part.dart';
import '../services/storage_service.dart';
import '../utils/currency_formatter.dart';

class AddRecordScreen extends StatefulWidget {
  final String carId;
  final MaintenanceRecord? recordToEdit;

  const AddRecordScreen({
    Key? key,
    required this.carId,
    this.recordToEdit,
  }) : super(key: key);

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _notesController = TextEditingController();
  final _laborCostController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<MaintenancePart> _parts = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      _loadExistingRecord();
    }
  }

  void _loadExistingRecord() {
    final record = widget.recordToEdit!;
    _selectedDate = record.date;
    _dateController.text = _formatDate(_selectedDate);
    _mileageController.text = record.mileage.toString();
    _serviceTypeController.text = record.serviceType;
    _notesController.text = record.notes;
    _laborCostController.text = record.laborCost.toString();
    _parts = List.from(record.parts);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _addPart() {
    showDialog(
      context: context,
      builder: (context) => _AddPartDialog(
        onAdd: (part) {
          setState(() {
            _parts.add(part);
          });
        },
      ),
    );
  }

  void _editPart(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddPartDialog(
        part: _parts[index],
        onAdd: (part) {
          setState(() {
            _parts[index] = part;
          });
        },
      ),
    );
  }

  void _removePart(int index) {
    setState(() {
      _parts.removeAt(index);
    });
  }

  void _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    final laborCost = double.parse(_laborCostController.text);
    final record = MaintenanceRecord(
      id: widget.recordToEdit?.id,
      carId: widget.carId,
      date: _selectedDate,
      mileage: int.parse(_mileageController.text),
      serviceType: _serviceTypeController.text,
      parts: _parts,
      notes: _notesController.text,
      laborCost: laborCost,
      totalCost: laborCost + _parts.fold(0.0, (sum, part) => sum + part.cost),
    );

    final storage = await StorageService.getInstance();
    if (widget.recordToEdit != null) {
      await storage.updateMaintenanceRecord(record);
    } else {
      await storage.addMaintenanceRecord(record);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recordToEdit != null ? 'Edit Record' : 'Add Record'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Service Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) =>
                  value?.isEmpty == true ? 'Please select a date' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(
                labelText: 'Mileage',
                suffixText: 'km',
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value?.isEmpty == true ? 'Please enter mileage' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceTypeController,
              decoration: const InputDecoration(
                labelText: 'Service Type',
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Please enter service type' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _laborCostController,
              decoration: const InputDecoration(
                labelText: 'Labor Cost',
                prefixText: '₹',
                hintText: '0.00',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.isEmpty == true) {
                  return 'Please enter labor cost';
                }
                if (double.tryParse(value!) == null) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Parts', style: TextStyle(fontSize: 16)),
                TextButton.icon(
                  onPressed: _addPart,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Part'),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _parts.length,
              itemBuilder: (context, index) {
                final part = _parts[index];
                return Card(
                  child: ListTile(
                    title: Text(part.name),
                    subtitle: Text('\$${part.cost.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editPart(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removePart(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveRecord,
              child: Text(widget.recordToEdit != null ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPartDialog extends StatefulWidget {
  final MaintenancePart? part;
  final Function(MaintenancePart) onAdd;

  const _AddPartDialog({
    Key? key,
    this.part,
    required this.onAdd,
  }) : super(key: key);

  @override
  _AddPartDialogState createState() => _AddPartDialogState();
}

class _AddPartDialogState extends State<_AddPartDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.part != null) {
      _nameController.text = widget.part!.name;
      _costController.text = widget.part!.cost.toString();
      _descriptionController.text = widget.part!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.part != null ? 'Edit Part' : 'Add Part'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Part Name',
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter part name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                  prefixText: '₹',
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Please enter cost';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd(MaintenancePart(
                name: _nameController.text,
                cost: double.parse(_costController.text),
                description: _descriptionController.text,
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 