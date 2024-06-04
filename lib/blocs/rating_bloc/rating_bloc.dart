import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rating_repository/rating_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final RatingRepo _ratingRepo;
  final UserRepository _userRepository;
  StreamSubscription? _ratingSubscription;

  RatingBloc({required RatingRepo ratingRepo, required UserRepository userRepo})
      : _ratingRepo = ratingRepo,
        _userRepository = userRepo,
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
      _ratingSubscription = ratingRepo.getRatingsByShopId(event.shopId, event.orderBy).listen(
              (ratings) async {
            final ratingsWithUser = await Future.wait(
              ratings.map((rating) => _fetchUserAndCombine(rating)).toList(),
            );
            add(UpdateRatings(ratingsWithUser));
          },
          onError: (error) {
            emit(RatingFailure());
            log('Error retrieving notifications: ${error.toString()}');
          }
      );
    });

    on<UpdateRatings>((event, emit) {
      emit(RatingsLoaded(ratingsWithUser: event.ratingsWithUsers));
    });
  }
  Future<RatingWithUser> _fetchUserAndCombine(Rating rating) async {
    final user = await _userRepository.getMyUser(rating.userId);
    return RatingWithUser(rating: rating, userName: user.name);
  }
}
