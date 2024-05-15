part of 'favorite_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class CreateFavorite extends FavoritesEvent {
  final String userId;
  final String shopId;

  const CreateFavorite(this.userId, this.shopId);

  @override
  List<Object> get props => [userId, shopId];
}

class DeleteFavorite extends FavoritesEvent {
  final String userId;
  final String shopId;

  const DeleteFavorite(this.userId, this.shopId);

  @override
  List<Object> get props => [userId, shopId];
}

class GetFavorite extends FavoritesEvent {
  final String userId;
  final String shopId;

  const GetFavorite(this.userId, this.shopId);

  @override
  List<Object> get props => [userId, shopId];
}

class LoadUserFavorites extends FavoritesEvent {
  final String userId;

  const LoadUserFavorites(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadShopFavorites extends FavoritesEvent {
  final String shopId;

  const LoadShopFavorites(this.shopId);

  @override
  List<Object> get props => [shopId];
}
