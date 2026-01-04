import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings();

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(settings);
      _initialized = true;
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    try {
      await initialize();

      const androidDetails = AndroidNotificationDetails(
        'water_reminder',
        'Pengingat Minum Air',
        channelDescription: 'Notifikasi untuk mengingatkan minum air',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(0, title, body, details);
    } catch (e) {
      print('Failed to show notification: $e');
    }
  }

  // Schedule periodic notifications
  Future<void> scheduleReminder(int intervalMinutes) async {
    try {
      await initialize();

      await _notifications.periodicallyShow(
        1,
        'Waktunya Minum Air! 💧',
        'Jangan lupa minum air ya!',
        RepeatInterval.hourly, // You can customize this
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminder',
            'Pengingat Minum Air',
            importance: Importance.high,
          ),
        ),
      );
    } catch (e) {
      print('Failed to schedule reminder: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      print('Failed to cancel notifications: $e');
    }
  }
}
