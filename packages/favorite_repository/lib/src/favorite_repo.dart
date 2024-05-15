import 'models/models.dart';

abstract class FavoriteRepo {
  Future<Favorite> createFavorite(String userId, String shopId);

  Future<void> deleteFavorite(String userId, String shopId);

  Future<List<Favorite>> getUserFavorites(String userId);

  Future<List<Favorite>> getShopFavorites(String shopId);

  Future<Favorite?> getFavorite(String userId, String shopId);
}
