import 'package:flutter/material.dart';
import '../models/service_interval.dart';
import '../services/storage_service.dart';
import '../widgets/service_interval_form.dart';

class ServiceScheduleScreen extends StatefulWidget {
  final String carId;

  const ServiceScheduleScreen({Key? key, required this.carId}) : super(key: key);

  @override
  _ServiceScheduleScreenState createState() => _ServiceScheduleScreenState();
}

class _ServiceScheduleScreenState extends State<ServiceScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StorageService _storageService;
  List<ServiceInterval> _intervals = [];
  List<Map<String, dynamic>> _upcomingServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    _storageService = StorageService(await SharedPreferences.getInstance());
    await _loadData();
    setState(() => _isLoading = false);
  }

  Future<void> _loadData() async {
    final intervals = await _storageService.getServiceIntervals(widget.carId);
    final upcomingServices = await _storageService.getUpcomingServices(widget.carId);
    
    setState(() {
      _intervals = intervals;
      _upcomingServices = upcomingServices;
    });
  }

  Future<void> _addServiceInterval() async {
    final result = await showDialog<ServiceInterval>(
      context: context,
      builder: (context) => ServiceIntervalForm(carId: widget.carId),
    );

    if (result != null) {
      await _storageService.saveServiceInterval(result);
      await _loadData();
    }
  }

  Future<void> _editServiceInterval(ServiceInterval interval) async {
    final result = await showDialog<ServiceInterval>(
      context: context,
      builder: (context) => ServiceIntervalForm(
        carId: widget.carId,
        interval: interval,
      ),
    );

    if (result != null) {
      await _storageService.saveServiceInterval(result);
      await _loadData();
    }
  }

  Future<void> _deleteServiceInterval(String intervalId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service Interval'),
        content: const Text('Are you sure you want to delete this service interval?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteServiceInterval(intervalId);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Schedule'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming Services'),
            Tab(text: 'Service Intervals'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingServicesTab(),
                _buildServiceIntervalsTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _addServiceInterval,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildUpcomingServicesTab() {
    if (_upcomingServices.isEmpty) {
      return const Center(
        child: Text('No upcoming services'),
      );
    }

    return ListView.builder(
      itemCount: _upcomingServices.length,
      itemBuilder: (context, index) {
        final service = _upcomingServices[index];
        final interval = service['interval'] as ServiceInterval;
        final isDueByTime = service['isDueByTime'] as bool;
        final isDueByMileage = service['isDueByMileage'] as bool;
        final daysSinceService = service['daysSinceService'] as int;
        final mileageSinceService = service['mileageSinceService'] as int;

        final bool isOverdue = isDueByTime || isDueByMileage;

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              interval.serviceName,
              style: TextStyle(
                color: isOverdue ? Colors.red : null,
                fontWeight: isOverdue ? FontWeight.bold : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time since last service: ${daysSinceService} days'),
                Text('Mileage since last service: ${mileageSinceService} km'),
                if (isDueByTime)
                  Text(
                    'Due by time (${interval.timeInterval} days)',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (isDueByMileage)
                  Text(
                    'Due by mileage (${interval.mileageInterval} km)',
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildServiceIntervalsTab() {
    if (_intervals.isEmpty) {
      return const Center(
        child: Text('No service intervals defined'),
      );
    }

    return ListView.builder(
      itemCount: _intervals.length,
      itemBuilder: (context, index) {
        final interval = _intervals[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(interval.serviceName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time interval: ${interval.timeInterval} days'),
                Text('Mileage interval: ${interval.mileageInterval} km'),
                if (interval.description.isNotEmpty)
                  Text('Description: ${interval.description}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _editServiceInterval(interval);
                } else if (value == 'delete') {
                  _deleteServiceInterval(interval.id);
                }
              },
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
} 