import 'models/models.dart';

abstract class ShopRepo {
  Future<List<MyShop>> getShops();

}