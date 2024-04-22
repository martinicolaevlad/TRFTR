import 'models/models.dart';

abstract class ShopRepo {
  Future<List<MyShop>> getShops();
  Future<MyShop?> getShopByOwnerId(String ownerId);

  Future <MyShop>createShop(MyShop shop);

}