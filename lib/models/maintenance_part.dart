class MaintenancePart {
  final String name;
  final double cost;
  final String description;

  MaintenancePart({
    required this.name,
    required this.cost,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cost': cost,
      'description': description,
    };
  }

  factory MaintenancePart.fromMap(Map<String, dynamic> map) {
    return MaintenancePart(
      name: map['name'] as String,
      cost: map['cost'] as double,
      description: map['description'] as String? ?? '',
    );
  }
} 