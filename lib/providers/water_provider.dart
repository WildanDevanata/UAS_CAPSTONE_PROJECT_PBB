import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/water_log.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/helpers.dart';

class WaterProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notif = NotificationService.instance;

  List<WaterLog> _todayLogs = [];
  double _dailyTarget = 2000.0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WaterLog> get todayLogs => _todayLogs;
  double get dailyTarget => _dailyTarget;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalToday {
    return _todayLogs.fold(0.0, (sum, log) => sum + log.amount);
  }

  double get progress {
    return Helpers.calculateProgress(totalToday, _dailyTarget);
  }

  bool get targetReached => totalToday >= _dailyTarget;

  // ✅ UPDATED: Initialize dengan load target
  Future<void> initialize() async {
    await loadDailyTarget();
    await loadTodayLogs();
  }

  // ✅ NEW: Load daily target dari database
  Future<void> loadDailyTarget() async {
    try {
      final settings = await _db.getSettings();
      _dailyTarget = settings.dailyTarget;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load daily target: $e');
      // Keep default value if error
    }
  }

  // ✅ NEW: Update daily target (called from SettingsProvider)
  void updateDailyTarget(double newTarget) {
    _dailyTarget = newTarget;
    notifyListeners();
  }

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

  Future<void> addWaterLog({required double amount, File? photo}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final log = WaterLog(
        dateTime: DateTime.now(),
        amount: amount,
        photoPath: photo?.path,
      );

      await _db.insertWaterLog(log);
      await loadTodayLogs();

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

  Future<Map<DateTime, double>> getWeeklyData() async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day - 6);
      final endDate = DateTime(now.year, now.month, now.day + 1);

      final logs = await _db.getLogsByDateRange(startDate, endDate);

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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
