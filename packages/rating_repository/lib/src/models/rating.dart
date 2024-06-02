import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

class Rating extends Equatable {
  final String id;
  final String userId;
  final String shopId;
  final int rating;
  final String review;
  final DateTime time;

  const Rating({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.rating,
    required this.review,
    required this.time,
  });

  Rating copyWith({
    String? id,
    String? userId,
    String? shopId,
    int? rating,
    String? review,
    DateTime? time,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      time: time ?? this.time,
    );
  }

  RatingEntity toEntity() {
    return RatingEntity(
      id: id,
      userId: userId,
      shopId: shopId,
      rating: rating,
      review: review,
      time: time,
    );
  }

  static Rating fromEntity(RatingEntity entity) {
    return Rating(
      id: entity.id,
      userId: entity.userId,
      shopId: entity.shopId,
      rating: entity.rating,
      review: entity.review,
      time: entity.time,
    );
  }

  @override
  List<Object?> get props => [id, userId, shopId, rating, review, time];

  @override
  String toString() {
    return 'Rating: { id: $id, userId: $userId, shopId: $shopId, rating: $rating, review: $review, time: $time }';
  }
}
