part of 'rating_bloc.dart';

abstract class RatingState extends Equatable {
  const RatingState();
}

class RatingInitial extends RatingState {
  @override
  List<Object> get props => [];
}

class RatingLoading extends RatingState {
  @override
  List<Object> get props => [];
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
