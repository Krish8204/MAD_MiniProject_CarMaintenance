import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/storage_service.dart';
import 'profile_screen.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  List<Car> _cars = [];
  late final StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _initializeStorageService();
  }

  Future<void> _initializeStorageService() async {
    _storageService = await StorageService.getInstance();
    await _loadCars();
  }

  Future<void> _loadCars() async {
    final cars = await _storageService.getCars();
    setState(() {
      _cars = cars;
    });
  }

  Future<void> _deleteCar(String carId) async {
    await _storageService.deleteCar(carId);
    await _loadCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cars'),
      ),
      body: _cars.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No cars added yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      ).then((_) => _loadCars());
                    },
                    child: const Text('Add Your First Car'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _cars.length,
              itemBuilder: (context, index) {
                final car = _cars[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.directions_car),
                    ),
                    title: Text(car.name),
                    subtitle: Text('${car.model} (${car.year})'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(car: car),
                              ),
                            ).then((_) => _loadCars());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteCar(car.id),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to car details or maintenance view
                      Navigator.pushNamed(
                        context,
                        '/car_details',
                        arguments: car,
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          ).then((_) => _loadCars());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 