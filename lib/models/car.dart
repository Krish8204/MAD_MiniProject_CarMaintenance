import 'package:uuid/uuid.dart';
import 'service_interval.dart';

class Car {
  final String id;
  final String name;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String? imageUrl;
  final int currentMileage;
  final List<ServiceInterval> serviceIntervals;

  Car({
    String? id,
    String? name,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.imageUrl,
    this.currentMileage = 0,
    List<ServiceInterval>? serviceIntervals,
  }) : id = id ?? const Uuid().v4(),
       name = name ?? '$year $make $model',
       serviceIntervals = serviceIntervals ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'imageUrl': imageUrl,
      'currentMileage': currentMileage,
      'serviceIntervals': serviceIntervals.map((interval) => interval.toMap()).toList(),
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'] as String? ?? const Uuid().v4(),
      name: map['name'] as String?,
      make: map['make'] as String? ?? '',
      model: map['model'] as String? ?? '',
      year: (map['year'] as num?)?.toInt() ?? DateTime.now().year,
      licensePlate: map['licensePlate'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      currentMileage: (map['currentMileage'] as num?)?.toInt() ?? 0,
      serviceIntervals: (map['serviceIntervals'] as List?)
          ?.map((interval) => ServiceInterval.fromMap(interval as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Car copyWith({
    String? name,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? imageUrl,
    int? currentMileage,
    List<ServiceInterval>? serviceIntervals,
  }) {
    return Car(
      id: id,
      name: name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      imageUrl: imageUrl ?? this.imageUrl,
      currentMileage: currentMileage ?? this.currentMileage,
      serviceIntervals: serviceIntervals ?? this.serviceIntervals,
    );
  }
}