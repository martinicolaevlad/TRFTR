import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../shop_repository.dart';

class FirebaseShopRepo implements ShopRepo {
  final shopCollection = FirebaseFirestore.instance.collection('shops');

  Future<MyShop> createShop(MyShop shop) async {
    try {
      shop.id = const Uuid().v1();


      await shopCollection
          .doc(shop.id)
          .set(shop.toEntity().toDocument());

      return shop;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }


  @override
  Future<List<MyShop>> getShops() async {
    try {
      final querySnapshot = await shopCollection.get();

      // Log the data retrieved from Firestore
      for (final doc in querySnapshot.docs) {
        log('Shop Document: ${doc.data()}');
      }
      return await shopCollection
          .get()
          .then((value) => value.docs.map((e) =>
          MyShop.fromEntity(MyShopEntity.fromDocument(e.data()))
      ).toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyShop?> getShopByOwnerId(String ownerId) async {
    try {
      final querySnapshot = await shopCollection.where('ownerId', isEqualTo: ownerId).get();
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        log('Shop found for owner: ${doc.data()}');
        return MyShop.fromEntity(MyShopEntity.fromDocument(doc.data()));
      } else {
        log('No shop found for ownerId: $ownerId');
        return null;
      }
    } catch (e) {
      log('Error fetching shop by ownerId $ownerId: ${e.toString()}');
      rethrow;
    }
  }
}
