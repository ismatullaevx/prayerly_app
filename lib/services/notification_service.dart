import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '../models/prayer.dart';
import 'dart:io' show Platform;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux) return;
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // For iOS, simple initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    if (Platform.isWindows || Platform.isLinux) return;
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  int _getPrayerId(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return 1;
      case PrayerType.dhuhr:
        return 2;
      case PrayerType.asr:
        return 3;
      case PrayerType.maghrib:
        return 4;
      case PrayerType.isha:
        return 5;
    }
  }

  Future<void> cancelAllNotifications() async {
    if (Platform.isWindows || Platform.isLinux) return;
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> schedulePrayerNotifications(
      List<Prayer> prayers, 
      bool notificationsEnabled, 
      Map<String, bool> individualSettings,
      String Function(String) getTranslation) async {
    
    if (Platform.isWindows || Platform.isLinux) return;
    
    await cancelAllNotifications();

    if (!notificationsEnabled) return;

    final now = DateTime.now();
    final format = DateFormat.jm(); // Matches the format from RealPrayerService

    for (var prayer in prayers) {
      final isEnabled = individualSettings[prayer.type.name] ?? true;
      if (!isEnabled) continue;

      // Parse the time
      try {
        final parsedTime = format.parse(prayer.time);
        final prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          parsedTime.hour,
          parsedTime.minute,
        );

        if (prayerDateTime.isAfter(now)) {
          final tzDateTime = tz.TZDateTime.from(prayerDateTime, tz.local);
          
          final title = getTranslation(prayer.type.name);
          
          String bodyKey = 'notificationBody';
          String body = getTranslation(bodyKey);
          body = body.replaceAll('%s', title);

          await flutterLocalNotificationsPlugin.zonedSchedule(
            _getPrayerId(prayer.type),
            title,
            body,
            tzDateTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'prayer_channel_id',
                'Prayer Notifications',
                channelDescription: 'Notifications for prayer times',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      } catch (e) {
        // Ignore parse errors or scheduling errors
      }
    }
  }
}
