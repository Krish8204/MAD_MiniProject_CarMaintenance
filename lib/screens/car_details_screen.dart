import 'package:flutter/material.dart';
import '../models/car.dart';
import '../models/maintenance_record.dart';
import '../services/storage_service.dart';
import '../utils/currency_formatter.dart';
import 'add_record_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({Key? key, required this.car}) : super(key: key);

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MaintenanceRecord> _maintenanceRecords = [];
  late final StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeStorageService();
  }

  Future<void> _initializeStorageService() async {
    _storageService = await StorageService.getInstance();
    await _loadMaintenanceRecords();
  }

  Future<void> _loadMaintenanceRecords() async {
    final records = await _storageService.getCarMaintenanceRecords(widget.car.id);
    setState(() {
      _maintenanceRecords = records;
    });
  }

  Future<void> _deleteRecord(String recordId) async {
    await _storageService.deleteMaintenanceRecord(recordId);
    await _loadMaintenanceRecords();
  }

  Future<void> _editRecord(MaintenanceRecord record) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecordScreen(
          carId: widget.car.id,
          recordToEdit: record,
        ),
      ),
    );

    if (result == true) {
      await _loadMaintenanceRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Maintenance History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildMaintenanceHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecordScreen(
                carId: widget.car.id,
              ),
            ),
          );

          if (result == true) {
            await _loadMaintenanceRecords();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text(widget.car.name),
                    subtitle: Text('${widget.car.make} ${widget.car.model}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Year'),
                    subtitle: Text(widget.car.year.toString()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.speed),
                    title: const Text('Current Mileage'),
                    subtitle: Text('${widget.car.currentMileage} km'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.pin),
                    title: const Text('License Plate'),
                    subtitle: Text(widget.car.licensePlate),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceHistoryTab() {
    if (_maintenanceRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_circle_outlined, 
                 size: 64, 
                 color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No maintenance records yet',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _maintenanceRecords.length,
      itemBuilder: (context, index) {
        final record = _maintenanceRecords[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(
              'Service on ${record.date.day}/${record.date.month}/${record.date.year}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Total Cost: ${CurrencyFormatter.format(record.totalCost)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Service Details'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Date', '${record.date.day}/${record.date.month}/${record.date.year}'),
                    _buildDetailRow('Mileage', '${record.mileage} km'),
                    _buildDetailRow('Service Type', record.serviceType),
                    _buildDetailRow('Labor Cost', CurrencyFormatter.format(record.laborCost)),
                    const SizedBox(height: 16),
                    if (record.parts.isNotEmpty) ...[
                      _buildSectionTitle('Parts'),
                      const SizedBox(height: 8),
                      ...record.parts.map((part) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              part.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            if (part.description.isNotEmpty)
                              Text(
                                part.description,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                                ),
                              ),
                            Text(
                              'Cost: ${CurrencyFormatter.format(part.cost)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    if (record.notes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('Notes'),
                      const SizedBox(height: 8),
                      Text(record.notes),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _editRecord(record),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _deleteRecord(record.id),
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
} 