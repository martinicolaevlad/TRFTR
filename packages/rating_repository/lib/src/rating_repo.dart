import 'models/models.dart';

abstract class RatingRepo {
  Future<Rating> addRating(Rating rating);
  updateRating(String ratingId, {String? userId, String? shopId, int? rating, String? review, DateTime? time}) ;
  Future<Rating?> getRating(String userId, String shopId);
  Future<List<Rating?>> getRatingsByShopId(String shopId);
}
