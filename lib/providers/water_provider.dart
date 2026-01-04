import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/water_log.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../utils/helpers.dart';

// Proper state management dengan Provider
class WaterProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final ApiService _api = ApiService.instance;
  final NotificationService _notif = NotificationService.instance;

  // State variables dengan naming yang jelas
  List<WaterLog> _todayLogs = [];
  final double _dailyTarget = 2000.0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WaterLog> get todayLogs => _todayLogs;
  double get dailyTarget => _dailyTarget;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calculated values
  double get totalToday {
    return _todayLogs.fold(0.0, (sum, log) => sum + log.amount);
  }

  double get progress {
    return Helpers.calculateProgress(totalToday, _dailyTarget);
  }

  bool get targetReached => totalToday >= _dailyTarget;

  // Initialize
  Future<void> initialize() async {
    await loadTodayLogs();
  }

  // Load today's logs
  Future<void> loadTodayLogs() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _todayLogs = await _db.getTodayLogs();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat data: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Add water log dengan camera integration
  Future<void> addWaterLog({required double amount, File? photo}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Create log
      final log = WaterLog(
        dateTime: DateTime.now(),
        amount: amount,
        photoPath: photo?.path,
      );

      // Save to local database
      await _db.insertWaterLog(log);

      // Sync to API (dengan error handling)
      try {
        await _api.syncWaterLog(log);
      } catch (e) {
        debugPrint('API sync failed: $e');
        // Continue anyway, akan di-sync nanti
      }

      // Reload data
      await loadTodayLogs();

      // Show notification jika target tercapai
      if (targetReached) {
        await _notif.showNotification(
          title: 'Selamat! 🎉',
          body: 'Target harian Anda tercapai!',
        );
      }
    } catch (e) {
      _errorMessage = 'Gagal menambah data: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Delete log
  Future<void> deleteLog(int id) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _db.deleteWaterLog(id);
      await loadTodayLogs();
    } catch (e) {
      _errorMessage = 'Gagal menghapus data: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Take photo with camera
  Future<File?> takePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Gagal mengambil foto: $e';
      notifyListeners();
      return null;
    }
  }

  // Get logs for charts (last 7 days)
  Future<Map<DateTime, double>> getWeeklyData() async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day - 6);
      final endDate = DateTime(now.year, now.month, now.day + 1);

      final logs = await _db.getLogsByDateRange(startDate, endDate);

      // Group by date
      final Map<DateTime, double> data = {};

      for (var log in logs) {
        final date = DateTime(
          log.dateTime.year,
          log.dateTime.month,
          log.dateTime.day,
        );

        data[date] = (data[date] ?? 0) + log.amount;
      }

      return data;
    } catch (e) {
      debugPrint('Failed to get weekly data: $e');
      return {};
    }
  }

  // Helper untuk set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
