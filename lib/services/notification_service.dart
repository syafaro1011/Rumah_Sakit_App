import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Pastikan ada tanda kurung () di akhir
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings, // <--- TAMBAHKAN 'settings:' DI SINI
      onDidReceiveNotificationResponse: (details) {
        // Logic ketika notifikasi diklik
      },
    );
  }

  static Future<void> showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hospital_channel_id', 
      'Hospital Notifications', 
      channelDescription: 'Notifikasi sistem rumah sakit',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id: DateTime.now().millisecond, // ID unik setiap notifikasi agar tidak saling tindih
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}