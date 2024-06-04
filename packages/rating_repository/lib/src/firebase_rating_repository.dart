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
  Stream<Rating> getRating(String shopId, String userId) {
    return ratingsCollection
        .where('shopId', isEqualTo: shopId)
        .where('userId', isEqualTo: userId)
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
        return Rating.fromEntity(RatingEntity.fromDocument(snapshot.docs.first.data()));


    });
  }



  @override
  Stream<List<Rating>> getRatingsByShopId(String shopId) {
    return ratingsCollection
        .where('shopId', isEqualTo: shopId)
        // .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) =>
          Rating.fromEntity(RatingEntity.fromDocument(doc.data()))).toList();
        });
    }
  }


