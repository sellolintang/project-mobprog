import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool _isPermissionRequested = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    // flutter_local_notifications versi project ini dipakai untuk mobile.
    // Saat run di Edge/Web, kita skip agar tidak error plugin web.
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(initializationSettings);

    await requestNotificationPermission();

    _isInitialized = true;
  }

  static Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return false;

    if (_isPermissionRequested) return true;

    bool isGranted = true;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted =
      await androidImplementation.requestNotificationsPermission();

      isGranted = granted ?? true;
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
    _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      isGranted = granted ?? isGranted;
    }

    final MacOSFlutterLocalNotificationsPlugin? macOSImplementation =
    _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();

    if (macOSImplementation != null) {
      final bool? granted = await macOSImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      isGranted = granted ?? isGranted;
    }

    _isPermissionRequested = true;

    return isGranted;
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    if (!_isInitialized) {
      await init();
    }

    await requestNotificationPermission();

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'duta_kampus_channel',
      'Duta Kampus Notification',
      channelDescription: 'Notifikasi aplikasi Pemilihan Duta Kampus',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> showTestNotification() async {
    await showNotification(
      title: 'Tes Notifikasi',
      body: 'Notifikasi aplikasi Duta Kampus berhasil aktif.',
    );
  }
}