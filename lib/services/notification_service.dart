import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Gère la programmation des rappels locaux (alertes) liés aux cultures.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    await _configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Ouvrir');
    final initSettings = InitializationSettings(
      android: androidSettings,
      linux: linuxSettings,
      // macOS et Windows utilisent des réglages par défaut adaptés ; iOS
      // n'est pas ciblé dans ce projet (voir §3 du cahier des charges).
      macOS: const DarwinInitializationSettings(),
    );

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Configure le fuseau horaire local réel de l'appareil (et non UTC par
  /// défaut) afin que les rappels se déclenchent à l'heure attendue par
  /// l'exploitant.
  Future<void> _configureLocalTimeZone() async {
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // En cas d'échec (émulateur, permission, etc.), on reste sur le
      // fuseau par défaut de la librairie plutôt que de bloquer l'appli.
    }
  }

  /// Programme une notification locale pour une alerte, à la date d'échéance donnée.
  Future<int> schedule({
    required String titre,
    required String corps,
    required DateTime dateEcheance,
  }) async {
    await init();

    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);

    const androidDetails = AndroidNotificationDetails(
      'agrisuivi_alertes',
      'Alertes AgriSuivi',
      channelDescription: 'Rappels programmés pour vos cultures',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    final scheduledDate = tz.TZDateTime.from(dateEcheance, tz.local);

    // Si la date est déjà passée, on ne programme pas de notification différée.
    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _plugin.zonedSchedule(
        id,
        titre,
        corps,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    return id;
  }

  Future<void> cancel(int? notificationId) async {
    if (notificationId == null) return;
    await _plugin.cancel(notificationId);
  }
}
