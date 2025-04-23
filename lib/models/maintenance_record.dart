import 'package:uuid/uuid.dart';
import 'maintenance_part.dart';

class MaintenanceRecord {
  final String id;
  final String carId;
  final DateTime date;
  final int mileage;
  final String serviceType;
  final List<MaintenancePart> parts;
  final String notes;
  final double laborCost;
  final double totalCost;

  MaintenanceRecord({
    String? id,
    required this.carId,
    required this.date,
    required this.mileage,
    required this.serviceType,
    required this.parts,
    this.notes = '',
    required this.laborCost,
    required this.totalCost,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'date': date.toIso8601String(),
      'mileage': mileage,
      'serviceType': serviceType,
      'parts': parts.map((part) => part.toMap()).toList(),
      'notes': notes,
      'laborCost': laborCost,
      'totalCost': totalCost,
    };
  }

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      id: map['id'],
      carId: map['carId'],
      date: DateTime.parse(map['date']),
      mileage: map['mileage'],
      serviceType: map['serviceType'],
      parts: (map['parts'] as List<dynamic>)
          .map((part) => MaintenancePart.fromMap(part))
          .toList(),
      notes: map['notes'] ?? '',
      laborCost: map['laborCost'],
      totalCost: map['totalCost'],
    );
  }

  MaintenanceRecord copyWith({
    String? id,
    String? carId,
    DateTime? date,
    int? mileage,
    String? serviceType,
    List<MaintenancePart>? parts,
    String? notes,
    double? laborCost,
    double? totalCost,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      serviceType: serviceType ?? this.serviceType,
      parts: parts ?? this.parts,
      notes: notes ?? this.notes,
      laborCost: laborCost ?? this.laborCost,
      totalCost: totalCost ?? this.totalCost,
    );
  }

  // Calculate total cost of all parts
  double get partsCost => parts.fold(0, (sum, part) => sum + part.cost);

  // Recalculate total cost
  double calculateTotalCost() => laborCost + partsCost;
} 