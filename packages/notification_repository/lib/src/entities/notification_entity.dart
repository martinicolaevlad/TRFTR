import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String userId;
  final String text;
  final String? shopId;

  const NotificationEntity({
    required this.userId,
    required this.text,
    this.shopId,
  });

  @override
  List<Object?> get props => [userId, text, shopId];

  @override
  String toString() {
    return 'NotificationEntity: { userId: $userId, text: $text, shopId: $shopId}';
  }

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'text': text,
      'shopId': shopId
    };
  }

  static NotificationEntity fromDocument(Map<String, dynamic> doc) {
    return NotificationEntity(
      userId: doc['userId'] as String,
      text: doc['text'] as String,
      shopId: doc['shopId'] as String
    );
  }
}
