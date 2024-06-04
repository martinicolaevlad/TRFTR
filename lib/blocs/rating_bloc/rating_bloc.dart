import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rating_repository/rating_repository.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final RatingRepo _ratingRepo;
  StreamSubscription? _ratingSubscription;

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
            rating: event.rating,
            review: event.review,
            time: event.time
        );
        emit(RatingSuccess(rating));
      } catch (e) {
        emit(RatingFailure());
      }
    });
    //Single rating:
    on<GetRating>((event, emit) async {
      emit(RatingLoading());
      await _ratingSubscription?.cancel();
      _ratingSubscription =
          ratingRepo.getRating(event.shopId, event.userId).listen(
                  (rating) {
                add(RefreshRating(rating));
              },
              onError: (error) {
                emit(RatingFailure());
                log('Error retrieving notifications: ${error.toString()}');
              }
          );
    });

    on<RefreshRating>((event, emit) async {
      emit(RatingLoaded(rating: event.rating));
    });

    //All ratings:
    on<LoadRatings>((event, emit) async {
      emit(RatingLoading());
      await _ratingSubscription?.cancel();
      _ratingSubscription = ratingRepo.getRatingsByShopId(event.shopId).listen(
              (ratings) {
            add(UpdateRatings(ratings));
          },
          onError: (error) {
            emit(RatingFailure());
            log('Error retrieving notifications: ${error.toString()}');
          }
      );
    });

    on<UpdateRatings>((event, emit) {
      log("is aici broski");
      emit(RatingsLoaded(ratings: event.ratings));
    });
  }
}
