import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initToken() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _firebaseMessaging.getToken();
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> get notificationStream =>
      FirebaseFirestore.instance.collection("notifications").snapshots();

  static void showNotifications(QueryDocumentSnapshot<Map<String, dynamic>> event) {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      '001',
      'Local Notification',
      channelDescription: 'To send local notification',
    );

    const NotificationDetails details = NotificationDetails(android: androidNotificationDetails);

    flutterLocalNotificationsPlugin.show(
      01,
      event.get('text'), // Assuming 'text' is used for the notification body
      '', // Title can be left empty or you can add another field if needed
      details,
    );
  }
}
