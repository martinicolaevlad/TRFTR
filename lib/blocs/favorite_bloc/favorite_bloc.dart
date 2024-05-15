import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:favorite_repository/favorite_repository.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoriteRepo _favoritesRepo;

  FavoritesBloc({required FavoriteRepo favoritesRepo})
      : _favoritesRepo = favoritesRepo,
        super(FavoritesInitial()) {
    on<CreateFavorite>((event, emit) async {
      emit(FavoritesLoading());
      try {
        Favorite favorite = await _favoritesRepo.createFavorite(event.userId, event.shopId);
        emit(FavoritesSuccess(favorite));
      } catch (e) {
        emit(FavoritesFailure());
      }
    });

    on<DeleteFavorite>((event, emit) async {
      emit(FavoritesLoading());
      try {
        await _favoritesRepo.deleteFavorite(event.userId, event.shopId);
        emit(FavoritesSuccess(null));
      } catch (e) {
        emit(FavoritesFailure());
      }
    });

    on<GetFavorite>((event, emit) async {
      emit(FavoritesLoading());
      try {
        Favorite? favorite = await _favoritesRepo.getFavorite(event.userId, event.shopId);
        emit(FavoritesSuccess(favorite));
      } catch (e) {
        emit(FavoritesFailure());
      }
    });

    on<LoadUserFavorites>((event, emit) async {
      emit(FavoritesLoading());
      try {
        var favorites = await _favoritesRepo.getUserFavorites(event.userId);
        emit(FavoritesLoaded(favorites));
      } catch (e) {
        emit(FavoritesFailure());
      }
    });

    on<LoadShopFavorites>((event, emit) async {
      emit(FavoritesLoading());
      try {
        var favorites = await _favoritesRepo.getShopFavorites(event.shopId);
        emit(FavoritesLoaded(favorites));
      } catch (e) {
        emit(FavoritesFailure());
      }
    });
  }
}
