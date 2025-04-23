import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car.dart';
import '../models/maintenance_record.dart';
import '../models/maintenance_part.dart';
import '../models/service_interval.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String _carsKey = 'cars_data';
  static const String _maintenanceRecordsKey = 'maintenance_records';
  static const String _serviceIntervalsKey = 'service_intervals';
  late final SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    final instance = StorageService._();
    instance._prefs = await SharedPreferences.getInstance();
    return instance;
  }

  // Car methods
  Future<List<Car>> getCars() async {
    final String? carsJson = _prefs.getString(_carsKey);
    if (carsJson == null) return [];
    
    final List<dynamic> carsList = json.decode(carsJson);
    return carsList.map((json) => Car.fromMap(json)).toList();
  }

  Future<void> addCar(Car car) async {
    final cars = await getCars();
    cars.add(car);
    await _saveCars(cars);
  }

  Future<void> updateCar(Car updatedCar) async {
    final cars = await getCars();
    final index = cars.indexWhere((car) => car.id == updatedCar.id);
    if (index != -1) {
      cars[index] = updatedCar;
      await _saveCars(cars);
    }
  }

  Future<void> deleteCar(String carId) async {
    final cars = await getCars();
    cars.removeWhere((car) => car.id == carId);
    await _saveCars(cars);
    
    // Also delete associated maintenance records
    final records = await getMaintenanceRecords();
    records.removeWhere((record) => record.carId == carId);
    await _saveMaintenanceRecords(records);
  }

  Future<void> _saveCars(List<Car> cars) async {
    final String carsJson = json.encode(cars.map((car) => car.toMap()).toList());
    await _prefs.setString(_carsKey, carsJson);
  }

  // Maintenance record methods
  Future<List<MaintenanceRecord>> getMaintenanceRecords() async {
    try {
      final String? recordsJson = _prefs.getString(_maintenanceRecordsKey);
      if (recordsJson == null || recordsJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> recordsList = json.decode(recordsJson);
      return recordsList.map((json) => MaintenanceRecord.fromMap(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading maintenance records: $e');
      // If there's an error loading the records, return an empty list
      return [];
    }
  }

  Future<List<MaintenanceRecord>> getCarMaintenanceRecords(String carId) async {
    final records = await getMaintenanceRecords();
    return records.where((record) => record.carId == carId).toList();
  }

  Future<void> addMaintenanceRecord(MaintenanceRecord record) async {
    try {
      final records = await getMaintenanceRecords();
      records.add(record);
      await _saveMaintenanceRecords(records);
    } catch (e) {
      print('Error adding maintenance record: $e');
      rethrow;
    }
  }

  Future<void> updateMaintenanceRecord(MaintenanceRecord updatedRecord) async {
    try {
      final records = await getMaintenanceRecords();
      final index = records.indexWhere((record) => record.id == updatedRecord.id);
      if (index != -1) {
        records[index] = updatedRecord;
        await _saveMaintenanceRecords(records);
      }
    } catch (e) {
      print('Error updating maintenance record: $e');
      rethrow;
    }
  }

  Future<void> deleteMaintenanceRecord(String recordId) async {
    try {
      final records = await getMaintenanceRecords();
      records.removeWhere((record) => record.id == recordId);
      await _saveMaintenanceRecords(records);
    } catch (e) {
      print('Error deleting maintenance record: $e');
      rethrow;
    }
  }

  Future<void> _saveMaintenanceRecords(List<MaintenanceRecord> records) async {
    try {
      final String recordsJson = json.encode(records.map((record) => record.toMap()).toList());
      await _prefs.setString(_maintenanceRecordsKey, recordsJson);
    } catch (e) {
      print('Error saving maintenance records: $e');
      rethrow;
    }
  }

  // Get single car
  Future<Car?> getCar(String id) async {
    final cars = await getCars();
    try {
      return cars.firstWhere((car) => car.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get upcoming maintenance records for a specific car
  Future<List<MaintenanceRecord>> getUpcomingMaintenance({String? carId}) async {
    final records = await getMaintenanceRecords();
    final intervals = await getAllServiceIntervals();
    final now = DateTime.now();
    
    var filtered = records.where((record) {
      if (carId != null && record.carId != carId) return false;
      
      final interval = intervals.firstWhere(
        (i) => i.carId == record.carId && i.serviceName == record.serviceType,
        orElse: () => ServiceInterval(
          carId: record.carId,
          serviceName: record.serviceType,
          mileageInterval: 5000,
          timeInterval: 180,
        ),
      );
      
      final daysSinceService = now.difference(record.date).inDays;
      return daysSinceService >= interval.timeInterval;
    });
    
    return filtered.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  // Service interval methods
  Future<List<ServiceInterval>> getServiceIntervals(String carId) async {
    final String? data = _prefs.getString(_serviceIntervalsKey);
    if (data == null) return [];

    List<dynamic> jsonList = jsonDecode(data);
    List<ServiceInterval> intervals = jsonList
        .map((json) => ServiceInterval.fromMap(json))
        .where((interval) => interval.carId == carId)
        .toList();
    return intervals;
  }

  Future<void> saveServiceInterval(ServiceInterval interval) async {
    List<ServiceInterval> intervals = await getAllServiceIntervals();
    intervals.removeWhere((i) => i.id == interval.id);
    intervals.add(interval);
    await _saveAllServiceIntervals(intervals);
  }

  Future<void> deleteServiceInterval(String intervalId) async {
    List<ServiceInterval> intervals = await getAllServiceIntervals();
    intervals.removeWhere((interval) => interval.id == intervalId);
    await _saveAllServiceIntervals(intervals);
  }

  Future<List<ServiceInterval>> getAllServiceIntervals() async {
    final String? data = _prefs.getString(_serviceIntervalsKey);
    if (data == null) return [];

    List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => ServiceInterval.fromMap(json)).toList();
  }

  Future<void> _saveAllServiceIntervals(List<ServiceInterval> intervals) async {
    final String data = jsonEncode(intervals.map((i) => i.toMap()).toList());
    await _prefs.setString(_serviceIntervalsKey, data);
  }

  Future<void> initializeDefaultServiceIntervals(String carId) async {
    try {
      final defaultIntervals = ServiceInterval.getDefaultIntervals(carId);
      final existingIntervals = await getServiceIntervals(carId);
      
      if (existingIntervals.isEmpty) {
        for (final interval in defaultIntervals) {
          await saveServiceInterval(interval);
        }
      }
    } catch (e) {
      print('Error initializing default service intervals: $e');
      rethrow;
    }
  }

  // Get upcoming services based on both time and mileage
  Future<List<Map<String, dynamic>>> getUpcomingServices(String carId) async {
    List<ServiceInterval> intervals = await getServiceIntervals(carId);
    List<MaintenanceRecord> records = await getCarMaintenanceRecords(carId);
    Car? car = await getCar(carId);
    
    if (car == null) return [];

    List<Map<String, dynamic>> upcomingServices = [];
    
    for (var interval in intervals) {
      var lastService = records.lastWhere(
        (record) => record.serviceType == interval.serviceName,
        orElse: () => MaintenanceRecord(
          id: const Uuid().v4(),
          carId: carId,
          date: DateTime(1970),
          mileage: 0,
          serviceType: interval.serviceName,
          parts: [],
          notes: '',
          laborCost: 0,
          totalCost: 0,
        ),
      );

      int daysSinceService = DateTime.now().difference(lastService.date).inDays;
      int mileageSinceService = car.currentMileage - lastService.mileage;

      bool isDueByTime = daysSinceService >= interval.timeInterval;
      bool isDueByMileage = mileageSinceService >= interval.mileageInterval;

      if (isDueByTime || isDueByMileage) {
        upcomingServices.add({
          'interval': interval,
          'daysSinceService': daysSinceService,
          'mileageSinceService': mileageSinceService,
          'isDueByTime': isDueByTime,
          'isDueByMileage': isDueByMileage,
        });
      }
    }

    return upcomingServices;
  }
} 