import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
  final String id;
  final String userId;
  final String shopId;
  final int rating; // Additional attribute for the rating

  const RatingEntity({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.rating,
  });

  @override
  List<Object?> get props => [id, userId, shopId, rating];

  @override
  String toString() {
    return 'RatingEntity: { id: $id, userId: $userId, shopId: $shopId, rating: $rating }';
  }

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'userId': userId,
      'shopId': shopId,
      'rating': rating,
    };
  }

  static RatingEntity fromDocument(Map<String, dynamic> doc) {
    return RatingEntity(
      id: doc['id'] as String,
      userId: doc['userId'] as String,
      shopId: doc['shopId'] as String,
      rating: doc['rating'] as int, // Ensure 'rating' is fetched as an int
    );
  }
}
