import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../favorite_repository.dart';

class FirebaseFavoriteRepo implements FavoriteRepo{
  final favoritesCollection = FirebaseFirestore.instance.collection('favorites');

  @override
  Future<Favorite> createFavorite(String userId, String shopId) async {
    try {
      String id = const Uuid().v1();
      var favorite = Favorite(id: id, userId: userId, shopId: shopId);
      await favoritesCollection.doc(id).set(favorite.toEntity().toDocument());
      log('Favorite created: ${favorite.toString()}');
      return favorite;
    } catch (e) {
      log('Error creating favorite: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> deleteFavorite(String userId, String shopId) async {
    try {
      var querySnapshot = await favoritesCollection
          .where('userId', isEqualTo: userId)
          .where('shopId', isEqualTo: shopId)
          .get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      log('Favorite deleted for user $userId and shop $shopId');
    } catch (e) {
      log('Error deleting favorite: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<Favorite>> getUserFavorites(String userId) async {
    try {
      var querySnapshot = await favoritesCollection.where('userId', isEqualTo: userId).get();
      return querySnapshot.docs.map((doc) => Favorite.fromEntity(FavoriteEntity.fromDocument(doc.data()))).toList();
    } catch (e) {
      log('Error retrieving user favorites for $userId: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<Favorite>> getShopFavorites(String shopId) async {
    try {
      var querySnapshot = await favoritesCollection.where('shopId', isEqualTo: shopId).get();
      return querySnapshot.docs.map((doc) => Favorite.fromEntity(FavoriteEntity.fromDocument(doc.data()))).toList();
    } catch (e) {
      log('Error retrieving shop favorites for $shopId: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Favorite?> getFavorite(String userId, String shopId) async {
    try {
      var querySnapshot = await favoritesCollection
          .where('userId', isEqualTo: userId)
          .where('shopId', isEqualTo: shopId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        log('Favorite found: ${querySnapshot.docs.first.data()}');
        return Favorite.fromEntity(FavoriteEntity.fromDocument(querySnapshot.docs.first.data()));
      } else {
        log('No favorite found for user $userId and shop $shopId');
        return null;
      }
    } catch (e) {
      log('Error retrieving favorite for user $userId and shop $shopId: ${e.toString()}');
      rethrow;
    }
  }
}
