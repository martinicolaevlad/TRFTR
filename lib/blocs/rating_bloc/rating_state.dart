part of 'rating_bloc.dart';

abstract class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState {}

class RatingLoading extends RatingState {}

class RatingsLoaded extends RatingState {
  final List<RatingWithUser> ratingsWithUser;

  const RatingsLoaded({this.ratingsWithUser = const <RatingWithUser>[]});

  @override
  List<Object?> get props => [ratingsWithUser];
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

class RatingWithUser {
  final Rating rating;
  final String userName;

  const RatingWithUser({required this.rating, required this.userName});
}
