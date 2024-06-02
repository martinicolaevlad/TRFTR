part of 'rating_bloc.dart';
abstract class RatingEvent extends Equatable {
  const RatingEvent();
}

class AddRating extends RatingEvent {
  final Rating rating;
  const AddRating(this.rating);
  @override
  List<Object> get props => [rating];
}

class UpdateRating extends RatingEvent {
  final String ratingId;
  final String userId;
  final String shopId;
  final int rating;
  final String review;
  final DateTime time;

  const UpdateRating({
    required this.ratingId,
    required this.userId,
    required this.shopId,
    required this.rating,
    required this.review,
    required this.time
  });

  @override
  List<Object?> get props => [ratingId, userId, shopId, rating, review, time];
}

class GetRating extends RatingEvent {
  final String shopId;
  final String userId;
  const GetRating(this.userId, this.shopId);
  @override
  List<Object> get props => [userId, shopId];
}

class GetRatingsByShopId extends RatingEvent {
  final String shopId;
  const GetRatingsByShopId(this.shopId);
  @override
  List<Object> get props => [shopId];
}
