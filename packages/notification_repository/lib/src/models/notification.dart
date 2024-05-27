import 'package:equatable/equatable.dart';

import '../../notification_repository.dart'; // Update the import path as needed

class MyNotification extends Equatable {
  final String userId;
  final String text;
  final String? shopId; // Optional shopId attribute

  const MyNotification({
    required this.userId,
    required this.text,
    this.shopId, // Initialize shopId as optional
  });

  MyNotification copyWith({
    String? userId,
    String? text,
    String? shopId,
  }) {
    return MyNotification(
      userId: userId ?? this.userId,
      text: text ?? this.text,
      shopId: shopId ?? this.shopId,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      userId: userId,
      text: text,
      shopId: shopId, // Include shopId in the entity conversion
    );
  }

  static MyNotification fromEntity(NotificationEntity entity) {
    return MyNotification(
      userId: entity.userId,
      text: entity.text,
      shopId: entity.shopId, // Obtain shopId from the entity
    );
  }

  @override
  List<Object?> get props => [userId, text, shopId]; // Add shopId to Equatable properties

  @override
  String toString() {
    return 'Notification: { userId: $userId, text: $text, shopId: $shopId }'; // Update toString method
  }
}
