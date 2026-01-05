import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ✅ CRITICAL: Initialize dengan permission request
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Android settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize
      final initialized = await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      if (initialized == null || !initialized) {
        debugPrint('Failed to initialize notifications');
        return false;
      }

      // ✅ REQUEST PERMISSION (Android 13+)
      await _requestPermissions();

      _initialized = true;
      debugPrint('Notifications initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      return false;
    }
  }

  // ✅ REQUEST NOTIFICATION PERMISSIONS
  Future<bool> _requestPermissions() async {
    try {
      // For Android 13+ (API 33+)
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('Android notification permission granted: $granted');
        return granted ?? false;
      }

      // For iOS
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permission granted: $granted');
        return granted ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  // ✅ SHOW IMMEDIATE NOTIFICATION (untuk testing)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Ensure initialized
      if (!_initialized) {
        await initialize();
      }

      // Android notification details
      const androidDetails = AndroidNotificationDetails(
        'waterlog_main', // channel id
        'WaterLog Notifications', // channel name
        channelDescription: 'Notifikasi untuk WaterLog app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      await _notifications.show(
        0, // notification id
        title,
        body,
        details,
        payload: payload,
      );

      debugPrint('Notification shown: $title');
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  // ✅ TEST NOTIFICATION (untuk debugging)
  Future<void> showTestNotification() async {
    await showNotification(
      title: 'Test Notifikasi 🔔',
      body: 'Jika Anda melihat ini, notifikasi berhasil!',
    );
  }

  // Schedule periodic notifications
  Future<void> scheduleReminder(int intervalMinutes) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      await _notifications.periodicallyShow(
        1,
        'Waktunya Minum Air! 💧',
        'Jangan lupa minum air ya!',
        RepeatInterval.hourly, // Every hour
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'waterlog_reminder',
            'Pengingat Minum Air',
            channelDescription: 'Pengingat berkala untuk minum air',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
        ),
      );

      debugPrint('Reminder scheduled');
    } catch (e) {
      debugPrint('Failed to schedule reminder: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Failed to cancel notifications: $e');
    }
  }

  // Check if permissions are granted
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }
}
