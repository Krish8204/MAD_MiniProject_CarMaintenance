import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/car.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  final Car? car;

  const ProfileScreen({Key? key, this.car}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _licensePlateController = TextEditingController();
  late final StorageService _storageService;
  bool _isLoading = false;
  String? _errorMessage;
  List<Car> _existingCars = [];

  @override
  void initState() {
    super.initState();
    _initializeStorageService();
    if (widget.car != null) {
      _makeController.text = widget.car!.make;
      _modelController.text = widget.car!.model;
      _yearController.text = widget.car!.year.toString();
      _mileageController.text = widget.car!.currentMileage.toString();
      _licensePlateController.text = widget.car!.licensePlate;
    }
  }

  Future<void> _initializeStorageService() async {
    _storageService = await StorageService.getInstance();
    _loadExistingCars();
  }

  Future<void> _loadExistingCars() async {
    _existingCars = await _storageService.getCars();
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final licensePlate = _licensePlateController.text.trim().toUpperCase();
      
      // Check for duplicate license plate
      if (widget.car == null || widget.car!.licensePlate != licensePlate) {
        final isDuplicate = _existingCars.any((car) => 
          car.licensePlate.toLowerCase() == licensePlate.toLowerCase());
        if (isDuplicate) {
          setState(() {
            _errorMessage = 'A car with this license plate already exists';
            _isLoading = false;
          });
          return;
        }
      }

      final car = Car(
        id: widget.car?.id,
        make: _makeController.text.trim().capitalize(),
        model: _modelController.text.trim().capitalize(),
        year: int.parse(_yearController.text.trim()),
        currentMileage: int.parse(_mileageController.text.trim()),
        licensePlate: licensePlate,
      );

      if (widget.car == null) {
        await _storageService.addCar(car);
      } else {
        await _storageService.updateCar(car);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.car == null ? 'Car added successfully' : 'Car updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save car: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car == null ? 'Add New Car' : 'Edit Car'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Card(
                  color: Colors.red[100],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Car Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _makeController,
                        decoration: const InputDecoration(
                          labelText: 'Make',
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the car make';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: 'Model',
                          prefixIcon: Icon(Icons.car_repair),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the car model';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the year';
                          }
                          final year = int.tryParse(value);
                          final currentYear = DateTime.now().year;
                          if (year == null || year < 1900 || year > currentYear) {
                            return 'Please enter a valid year between 1900 and $currentYear';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _licensePlateController,
                        decoration: const InputDecoration(
                          labelText: 'License Plate',
                          prefixIcon: Icon(Icons.pin),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the license plate number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mileageController,
                        decoration: const InputDecoration(
                          labelText: 'Current Mileage',
                          prefixIcon: Icon(Icons.speed),
                          suffixText: 'miles',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the current mileage';
                          }
                          final mileage = int.tryParse(value);
                          if (mileage == null || mileage < 0) {
                            return 'Please enter a valid mileage';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveCar,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text(
                  widget.car == null ? 'Add Car' : 'Save Changes',
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 