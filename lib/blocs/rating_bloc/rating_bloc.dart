import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rating_repository/rating_repository.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final RatingRepo _ratingRepo;

  RatingBloc({required RatingRepo ratingRepo})
      : _ratingRepo = ratingRepo,
        super(RatingInitial()) {
    on<AddRating>((event, emit) async {
      emit(RatingLoading());
      try {
        Rating rating = await _ratingRepo.addRating(event.rating);
        emit(RatingSuccess(rating));
      } catch (e) {
        emit(RatingFailure());
      }
    });

    on<UpdateRating>((event, emit) async {
      emit(RatingLoading());
      try {
        Rating rating = await _ratingRepo.updateRating(
          event.ratingId,
            userId: event.userId,
            shopId: event.shopId,
            rating: event.rating
        );
        emit(RatingSuccess(rating));
      } catch (e) {
        emit(RatingFailure());
      }
    });

    on<GetRating>((event, emit) async {
      emit(RatingLoading());
      try {
        Rating? rating = await _ratingRepo.getRating(event.userId, event.shopId);
        emit(RatingSuccess(rating));
      } catch (e) {
        emit(RatingFailure());
      }
    });
    on<GetRatingsByShopId>((event, emit) async {
        emit(RatingLoading());
        try {
          List<Rating?> rating = await _ratingRepo.getRatingsByShopId(event.shopId);
          emit(RatingSuccess(rating.first));
        } catch (e) {
          emit(RatingFailure());
        }
      });
    }
}
