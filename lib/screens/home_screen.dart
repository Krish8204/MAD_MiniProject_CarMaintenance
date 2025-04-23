import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_record.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = StorageService();
  List<MaintenanceRecord> _upcomingMaintenance = [];

  @override
  void initState() {
    super.initState();
    _loadUpcomingMaintenance();
  }

  Future<void> _loadUpcomingMaintenance() async {
    final records = await _storageService.getUpcomingMaintenance();
    setState(() {
      _upcomingMaintenance = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Maintenance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Maintenance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _upcomingMaintenance.isEmpty
                  ? const Center(
                      child: Text('No upcoming maintenance'),
                    )
                  : ListView.builder(
                      itemCount: _upcomingMaintenance.length,
                      itemBuilder: (context, index) {
                        final record = _upcomingMaintenance[index];
                        return Card(
                          child: ListTile(
                            title: Text(record.partName),
                            subtitle: Text(
                              'Due: ${DateFormat('MMM dd, yyyy').format(record.nextDueDate)}',
                            ),
                            trailing: Text(
                              '\$${record.cost.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add').then((_) {
                      _loadUpcomingMaintenance();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Record'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/history');
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 