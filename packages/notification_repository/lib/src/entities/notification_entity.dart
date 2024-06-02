import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String userId;
  final String text;
  final String shopId;
  final DateTime time;
  final bool? isSensitive;
  final bool? seen;

  const NotificationEntity({
    required this.userId,
    required this.text,
    required this.shopId,
    required this.time,
    this.isSensitive,
    this.seen,
  });

  @override
  List<Object?> get props => [userId, text, shopId, time, isSensitive, seen];

  @override
  String toString() {
    return 'NotificationEntity: { userId: $userId, text: $text, shopId: $shopId, time: $time, isSensitive: $isSensitive, seen: $seen }';
  }

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'text': text,
      'shopId': shopId,
      'time': time,
      'isSensitive': isSensitive,
      'seen': seen
    };
  }

  static NotificationEntity fromDocument(Map<String, dynamic> doc) {
    return NotificationEntity(
        userId: doc['userId'] as String,
        text: doc['text'] as String,
        shopId: doc['shopId'] as String,
        time: (doc['time'] as Timestamp).toDate(), // Convert Timestamp to DateTime
        isSensitive: doc['canPress'] as bool?,
        seen: doc['seen'] as bool?
    );
  }
}
