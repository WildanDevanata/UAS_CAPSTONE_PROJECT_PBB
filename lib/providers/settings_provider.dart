import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'water_provider.dart'; // ✅ Import this

class SettingsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notif = NotificationService.instance;

  UserSettings _settings = UserSettings();
  bool _isLoading = false;

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      notifyListeners();

      _settings = await _db.getSettings();

      if (_settings.notificationsEnabled) {
        await _notif.scheduleReminder(_settings.reminderInterval);
      }
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ UPDATED: Add context parameter untuk sync
  Future<void> updateSettings(
    UserSettings newSettings,
    BuildContext context, // ✅ NEW parameter
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _db.updateSettings(newSettings);
      _settings = newSettings;

      // ✅ SYNC dengan WaterProvider
      if (context.mounted) {
        final waterProvider = Provider.of<WaterProvider>(
          context,
          listen: false,
        );
        waterProvider.updateDailyTarget(newSettings.dailyTarget);
      }

      if (newSettings.notificationsEnabled) {
        await _notif.scheduleReminder(newSettings.reminderInterval);
      } else {
        await _notif.cancelAll();
      }
    } catch (e) {
      debugPrint('Failed to update settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
