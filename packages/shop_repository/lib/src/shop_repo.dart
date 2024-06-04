import 'models/models.dart';

abstract class ShopRepo {
  Future<List<MyShop>> getShops();
  Stream<List<MyShop>>getShopsStream();

  Future<MyShop?> getShopByOwnerId(String ownerId);

  Future<MyShop?> getShopById(String id);

  Future<MyShop>createShop(MyShop shop);

  updateShopDetails(String shopId, {String? name, int? rating, String? picture, DateTime? nextDrop, DateTime? lastDrop, String? latitude, String? longitude, int? openTime, int? closeTime, String? ownerId, String? details, int? ratingsCount}) {}

  Future<void> uploadPicture(String file, String shopId);
}