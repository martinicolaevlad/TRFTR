import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../notification_repository.dart';
class FirebaseNotificationRepo implements NotificationRepo {
  final notificationsCollection = FirebaseFirestore.instance.collection('notifications');

  @override
  Stream<List<MyNotification>> getNotificationsByUserId(String userId) {
    return notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) =>
          MyNotification.fromEntity(NotificationEntity.fromDocument(doc.data()))
      ).toList();
    });
  }

}

