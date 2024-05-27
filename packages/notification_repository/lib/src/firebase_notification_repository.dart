import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../notification_repository.dart';
class FirebaseNotificationRepo implements NotificationRepo {
  final notificationsCollection = FirebaseFirestore.instance.collection('notifications');

  @override
  Future<List<MyNotification>> getNotificationsByUserId(String userId) async {
    try {
      var querySnapshot = await notificationsCollection.where('userId', isEqualTo: userId).get();
      return querySnapshot.docs.map((doc) => MyNotification.fromEntity(NotificationEntity.fromDocument(doc.data()))).toList();
    } catch (e) {
      log('Error retrieving notifications for $userId: ${e.toString()}');
      rethrow;
    }
  }
}
