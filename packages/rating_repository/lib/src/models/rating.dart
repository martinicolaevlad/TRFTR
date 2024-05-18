import 'package:equatable/equatable.dart';

import '../entities/entities.dart';

class Rating extends Equatable {
  final String id;
  final String userId;
  final String shopId;
  final int rating;

  const Rating({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.rating,
  });

  Rating copyWith({
    String? id,
    String? userId,
    String? shopId,
    int? rating,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      rating: rating ?? this.rating,
    );
  }

  RatingEntity toEntity() {
    return RatingEntity(
      id: id,
      userId: userId,
      shopId: shopId,
      rating: rating,
    );
  }

  static Rating fromEntity(RatingEntity entity) {
    return Rating(
      id: entity.id,
      userId: entity.userId,
      shopId: entity.shopId,
      rating: entity.rating,
    );
  }

  @override
  List<Object?> get props => [id, userId, shopId, rating];

  @override
  String toString() {
    return 'Rating: { id: $id, userId: $userId, shopId: $shopId, rating: $rating }';
  }
}
