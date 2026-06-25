import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);

    // Request notification permission for Android 13+ (API 33+)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> schedulePrayerNotification({
    required int id,
    required String sholatName,
    required DateTime time,
  }) async {
    final now = DateTime.now();
    DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      'Waktu Sholat $sholatName Telah Tiba',
      'Mari tunaikan ibadah sholat $sholatName tepat waktu.',
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_reminder_channel',
          'Pengingat Waktu Sholat',
          channelDescription: 'Saluran notifikasi adzan dan pengingat sholat fardhu',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Membuat berulang setiap hari
    );
  }

  /// Menghapus semua reminder jika fitur dinonaktifkan di halaman setting
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}