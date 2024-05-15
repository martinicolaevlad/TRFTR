part of 'favorite_bloc.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Favorite> favorites;

  const FavoritesLoaded(this.favorites);

  @override
  List<Object> get props => [favorites];
}

class FavoritesSuccess extends FavoritesState {
  final Favorite? favorite;

  const FavoritesSuccess(this.favorite);

}

class FavoritesFailure extends FavoritesState {}
