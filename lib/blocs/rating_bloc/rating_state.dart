part of 'rating_bloc.dart';

abstract class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState {}

class RatingLoading extends RatingState {}

class RatingsLoaded extends RatingState {
  final List<Rating> ratings;

  const RatingsLoaded({this.ratings = const <Rating>[]});
  @override
  List<Object?> get props => [ratings];
}
class RatingLoaded extends RatingState {
  final Rating rating;

  const RatingLoaded({required this.rating});
  @override
  List<Object?> get props => [rating];
}

class RatingSuccess extends RatingState {
  final Rating? rating;
  const RatingSuccess(this.rating);
  @override
  List<Object?> get props => [rating];
}

class RatingFailure extends RatingState {
  @override
  List<Object> get props => [];
}
