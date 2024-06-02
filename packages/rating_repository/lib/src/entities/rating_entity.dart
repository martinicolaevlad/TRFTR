import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
  final String id;
  final String userId;
  final String shopId;
  final int rating;
  final String review;
  final DateTime time;

  const RatingEntity({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.rating,
    required this.review,
    required this.time,
  });

  @override
  List<Object?> get props => [id, userId, shopId, rating, review, time];

  @override
  String toString() {
    return 'RatingEntity: { id: $id, userId: $userId, shopId: $shopId, rating: $rating, review: $review, time: $time }';
  }

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'userId': userId,
      'shopId': shopId,
      'rating': rating,
      'review': review,
      'time': time,
    };
  }

  static RatingEntity fromDocument(Map<String, dynamic> doc) {
    return RatingEntity(
      id: doc['id'] as String,
      userId: doc['userId'] as String,
      shopId: doc['shopId'] as String,
      rating: doc['rating'] as int,
      review: doc['review'] as String,
      time: (doc['time'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }
}
