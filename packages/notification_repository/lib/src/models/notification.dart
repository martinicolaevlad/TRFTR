import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../notification_repository.dart'; // Update the import path as needed

class MyNotification extends Equatable {
  final String userId;
  final String text;
  final String shopId;
  final DateTime time;
  final bool? isSensitive;
  final bool? seen;

  const MyNotification({
    required this.userId,
    required this.text,
    required this.shopId,
    required this.time,
    this.isSensitive,
    this.seen,
  });

  MyNotification copyWith({
    String? userId,
    String? text,
    String? shopId,
    DateTime? time,
    bool? isSensitive,
    bool? seen,
  }) {
    return MyNotification(
      userId: userId ?? this.userId,
      text: text ?? this.text,
      shopId: shopId ?? this.shopId,
      time: time ?? this.time,
      isSensitive: isSensitive ?? this.isSensitive,
      seen: seen ?? this.seen,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      userId: userId,
      text: text,
      shopId: shopId,
      time: time,
      isSensitive: isSensitive,
      seen: seen,
    );
  }

  static MyNotification fromEntity(NotificationEntity entity) {
    return MyNotification(
      userId: entity.userId,
      text: entity.text,
      shopId: entity.shopId,
      time: entity.time,
      isSensitive: entity.isSensitive,
      seen: entity.seen,
    );
  }

  @override
  List<Object?> get props => [userId, text, shopId, time, isSensitive, seen];

  @override
  String toString() {
    return 'Notification: { userId: $userId, text: $text, shopId: $shopId, time: $time, isSensitive: $isSensitive, seen: $seen }';
  }
}
