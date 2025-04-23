import 'package:uuid/uuid.dart';

class ServiceInterval {
  final String id;
  final String carId;
  final String serviceName;
  final int mileageInterval;
  final int timeInterval;
  final String description;
  final DateTime? lastServiceDate;
  final int? lastServiceMileage;

  ServiceInterval({
    String? id,
    required this.carId,
    required this.serviceName,
    required this.mileageInterval,
    required this.timeInterval,
    this.description = '',
    this.lastServiceDate,
    this.lastServiceMileage,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'serviceName': serviceName,
      'mileageInterval': mileageInterval,
      'timeInterval': timeInterval,
      'description': description,
      'lastServiceDate': lastServiceDate?.toIso8601String(),
      'lastServiceMileage': lastServiceMileage,
    };
  }

  factory ServiceInterval.fromMap(Map<String, dynamic> map) {
    return ServiceInterval(
      id: map['id'],
      carId: map['carId'],
      serviceName: map['serviceName'],
      mileageInterval: map['mileageInterval'],
      timeInterval: map['timeInterval'],
      description: map['description'] ?? '',
      lastServiceDate: map['lastServiceDate'] != null 
          ? DateTime.parse(map['lastServiceDate'])
          : null,
      lastServiceMileage: map['lastServiceMileage'],
    );
  }

  ServiceInterval copyWith({
    String? id,
    String? carId,
    String? serviceName,
    int? mileageInterval,
    int? timeInterval,
    String? description,
    DateTime? lastServiceDate,
    int? lastServiceMileage,
  }) {
    return ServiceInterval(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      serviceName: serviceName ?? this.serviceName,
      mileageInterval: mileageInterval ?? this.mileageInterval,
      timeInterval: timeInterval ?? this.timeInterval,
      description: description ?? this.description,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastServiceMileage: lastServiceMileage ?? this.lastServiceMileage,
    );
  }

  // Predefined service intervals
  static List<ServiceInterval> getDefaultIntervals(String carId) {
    return [
      ServiceInterval(
        carId: carId,
        serviceName: 'Oil Change',
        mileageInterval: 5000,
        timeInterval: 180,
        description: 'Regular oil change with filter replacement',
        lastServiceDate: DateTime.now().subtract(const Duration(days: 180)),
        lastServiceMileage: 5000,
      ),
      ServiceInterval(
        carId: carId,
        serviceName: 'Tire Rotation',
        mileageInterval: 10000,
        timeInterval: 180,
        description: 'Rotate tires for even wear',
        lastServiceDate: DateTime.now().subtract(const Duration(days: 180)),
        lastServiceMileage: 10000,
      ),
      ServiceInterval(
        carId: carId,
        serviceName: 'Brake Inspection',
        mileageInterval: 20000,
        timeInterval: 365,
        description: 'Check brake pads, rotors, and fluid',
        lastServiceDate: DateTime.now().subtract(const Duration(days: 365)),
        lastServiceMileage: 20000,
      ),
      ServiceInterval(
        carId: carId,
        serviceName: 'Air Filter',
        mileageInterval: 15000,
        timeInterval: 365,
        description: 'Replace engine air filter',
        lastServiceDate: DateTime.now().subtract(const Duration(days: 365)),
        lastServiceMileage: 15000,
      ),
    ];
  }
} 