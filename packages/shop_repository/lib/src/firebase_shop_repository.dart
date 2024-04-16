import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/src/models/models.dart';

import '../shop_repository.dart';


class FirebaseShopRepo implements ShopRepo {
  final shopCollection = FirebaseFirestore.instance.collection('shops');

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

}
