import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  Stream<List<MyShop>> getShopsStream() {
    return shopCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MyShop.fromEntity(MyShopEntity.fromDocument(doc.data()));
      }).toList();
    });
  }


  @override
  Future<MyShop?> getShopByOwnerId(String ownerId) async {
    try {
      final querySnapshot = await shopCollection.where('ownerId', isEqualTo: ownerId).get();
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
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

  @override
  Future<MyShop?> getShopById(String id) async {
    try {
      final querySnapshot = await shopCollection.where('id', isEqualTo: id).get();
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        return MyShop.fromEntity(MyShopEntity.fromDocument(doc.data()));
      } else {
        log('No shop found for id: $id');
        return null;
      }
    } catch (e) {
      log('Error fetching shop by ownerId $id: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> updateShopDetails(String shopId, {String? name, int? rating, String? picture, DateTime? nextDrop, DateTime? lastDrop, String? latitude, String? longitude, int? openTime, int? closeTime, String? ownerId, String? details, int? ratingsCount}) async {
    try {
      var updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (rating != null) updateData['rating'] = rating;
      if (picture != null) updateData['picture'] = picture;
      if (nextDrop != null) updateData['nextDrop'] = nextDrop;
      if (lastDrop != null) updateData['lastDrop'] = lastDrop;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;
      if (openTime != null) updateData['openTime'] = openTime;
      if (closeTime != null) updateData['closeTime'] = closeTime;
      if (ownerId != null) updateData['ownerId'] = ownerId;
      if (details != null) updateData['details'] = details;
      if (ratingsCount != null) updateData['ratingsCount'] = ratingsCount;

      await shopCollection.doc(shopId).update(updateData);
      log('Shop updated successfully: $shopId');
    } catch (e) {
      log('Error updating shop $shopId: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> uploadPicture(String file, String shopId) async {
    try {
      if (shopId.isEmpty) {
        throw Exception("Shop ID is empty.");
      }

      // Upload the picture and get the URL
      File imageFile = File(file);
      Reference firebaseStoreRef = FirebaseStorage.instance
          .ref()
          .child('ShopProfile/$shopId/${shopId}_lead');
      await firebaseStoreRef.putFile(imageFile);
      String url = await firebaseStoreRef.getDownloadURL();

      // Update the shop details with the new picture URL
      var updateData = <String, dynamic>{'picture': url};
      await shopCollection.doc(shopId).update(updateData);
      log('Shop updated with new picture successfully: $shopId');
    } catch (e) {
      log('Error updating shop $shopId with new picture: ${e.toString()}');
      rethrow;
    }
  }




}
