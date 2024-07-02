import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rating_repository/src/rating_repo.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import 'entities/entities.dart';
import 'models/models.dart';



class FirebaseRatingRepo implements RatingRepo {
  final ratingsCollection = FirebaseFirestore.instance.collection('ratings');

  @override
  Future<Rating> addRating(Rating rating) async {
    try {
      String id = const Uuid().v1();
      var newRating = Rating(
          id: id,
          userId: rating.userId,
          shopId: rating.shopId,
          rating: rating.rating,
          review: rating.review,
          time: rating.time
      );
      await ratingsCollection.doc(id).set(newRating.toEntity().toDocument());
      log('Rating added: ${newRating.toString()}');
      return newRating;
    } catch (e) {
      log('Error adding rating: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> updateRating(String ratingId, {String? userId, String? shopId, int? rating, String? review, DateTime? time}) async {
    try {
      var updateData = <String, dynamic>{};
      if (rating != null) updateData['rating'] = rating;
      if (userId != null) updateData['userId'] = userId;
      if (shopId != null) updateData['shopId'] = shopId;
      if (review != null) updateData['review'] = review;
      if (time != null) updateData['time'] = time;

      await ratingsCollection.doc(ratingId).update(updateData);
      log('Rating updated successfully: $ratingId');
    } catch (e) {
      log('Error updating rating $ratingId: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Rating?> getRating(String shopId, String userId) async {
    log("In repo");
    try{
    final querySnapshot = await ratingsCollection
        .where('shopId', isEqualTo: shopId)
        .where('userId', isEqualTo: userId)
       .get();
    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      return Rating.fromEntity(RatingEntity.fromDocument(doc.data()));
    } else {
      log('No rating found for shopId: $shopId from userId: $userId');
      return null;
    }
  } catch (e) {
  log('Error fetching shop by ownerId $shopId: ${e.toString()}');
  rethrow;
  }
  }



  @override
  Stream<List<Rating>> getRatingsByShopId(String shopId, String orderBy) {
    if (orderBy == 'latest') {
      return ratingsCollection
          .where('shopId', isEqualTo: shopId)
          .orderBy('time', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) =>
            Rating.fromEntity(RatingEntity.fromDocument(doc.data()))).toList();
      });
    } else if (orderBy == 'best') {
      return ratingsCollection
          .where('shopId', isEqualTo: shopId)
          .orderBy('rating', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) =>
            Rating.fromEntity(RatingEntity.fromDocument(doc.data()))).toList();
      });
    } else if (orderBy == 'worst') {
      return ratingsCollection
          .where('shopId', isEqualTo: shopId)
          .orderBy('rating', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) =>
            Rating.fromEntity(RatingEntity.fromDocument(doc.data()))).toList();
      });
    }
    return ratingsCollection
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) =>
          Rating.fromEntity(RatingEntity.fromDocument(doc.data()))).toList();

    });
  }}
