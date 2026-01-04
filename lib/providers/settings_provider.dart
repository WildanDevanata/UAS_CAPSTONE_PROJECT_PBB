import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notif = NotificationService.instance;

  UserSettings _settings = UserSettings();
  bool _isLoading = false;

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;

  // Initialize
  Future<void> initialize() async {
    await loadSettings();
  }

  // Load settings
  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      notifyListeners();

      _settings = await _db.getSettings();

      // Setup notifications based on settings
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

  // Update settings
  Future<void> updateSettings(UserSettings newSettings) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _db.updateSettings(newSettings);
      _settings = newSettings;

      // Update notifications
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
