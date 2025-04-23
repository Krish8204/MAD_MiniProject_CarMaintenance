import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/service_interval.dart';

class ServiceIntervalForm extends StatefulWidget {
  final String carId;
  final ServiceInterval? interval;

  const ServiceIntervalForm({
    Key? key,
    required this.carId,
    this.interval,
  }) : super(key: key);

  @override
  _ServiceIntervalFormState createState() => _ServiceIntervalFormState();
}

class _ServiceIntervalFormState extends State<ServiceIntervalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mileageController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.interval != null) {
      _nameController.text = widget.interval!.serviceName;
      _mileageController.text = widget.interval!.mileageInterval.toString();
      _timeController.text = widget.interval!.timeInterval.toString();
      _descriptionController.text = widget.interval!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.interval == null ? 'Add Service Interval' : 'Edit Service Interval'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  hintText: 'e.g., Oil Change, Tire Rotation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Mileage Interval (km)',
                  hintText: 'e.g., 5000',
                  border: OutlineInputBorder(),
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a mileage interval';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time Interval (days)',
                  hintText: 'e.g., 180',
                  border: OutlineInputBorder(),
                  suffixText: 'days',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time interval';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter any additional details or notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
        FilledButton(
          onPressed: _saveInterval,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveInterval() {
    if (_formKey.currentState!.validate()) {
      final interval = ServiceInterval(
        id: widget.interval?.id ?? const Uuid().v4(),
        carId: widget.carId,
        serviceName: _nameController.text.trim(),
        mileageInterval: int.parse(_mileageController.text),
        timeInterval: int.parse(_timeController.text),
        description: _descriptionController.text.trim(),
      );
      Navigator.pop(context, interval);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mileageController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 