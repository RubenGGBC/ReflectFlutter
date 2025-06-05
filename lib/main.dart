// ============================================================================
// main.dart - CON NOTIFICACIÓN DIARIA A LAS 22:30
// ============================================================================

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'injection_container.dart' as di;

// Plugin de notificaciones
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar base de datos en plataformas de escritorio
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Inicializar dependencias
    await di.init();

    // Inicializar zonas horarias
    tz.initializeTimeZones();

    // Inicializar notificaciones
    await _initNotifications();

    // Solicitar permisos (Android 13+)
    await _requestNotificationPermission();

    // Programar notificación diaria a las 22:30
    await _scheduleDailyNotification();

    runApp(const ReflectApp());

  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error inicializando ReflectApp'),
                Text('$e'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==============================
// INICIALIZACIÓN DE NOTIFICACIONES
// ==============================
Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

// ==============================
// PERMISOS EN ANDROID 13+
// ==============================

Future<void> _requestNotificationPermission() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    if (sdkInt >= 33) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        debugPrint('Permiso de notificación no concedido.');
      }
    }
  }
}


// ==============================
// PROGRAMAR NOTIFICACIÓN DIARIA A LAS 22:30
// ==============================
Future<void> _scheduleDailyNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    '¡Es hora de reflexionar!',
    'Abre Reflect y registra cómo te sientes hoy ✨',
    _nextInstanceOfTenThirtyPM(),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reflect_channel',
        'Recordatorio Diario',
        channelDescription: 'Te recuerda usar Reflect a las 22:30',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

// ==============================
// CALCULAR LA PRÓXIMA EJECUCIÓN A LAS 22:30
// ==============================
tz.TZDateTime _nextInstanceOfTenThirtyPM() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
  tz.TZDateTime(tz.local, now.year, now.month, now.day, 22, 30);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}
