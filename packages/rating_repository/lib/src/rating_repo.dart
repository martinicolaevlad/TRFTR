import '../rating_repository.dart';
import 'models/models.dart';

abstract class RatingRepo {
  Future<Rating> addRating(Rating rating);
  updateRating(String ratingId, {String? userId, String? shopId, int? rating, String? review, DateTime? time}) ;
  Stream<Rating> getRating(String shopId, String userId);
  Stream<List<Rating>> getRatingsByShopId(String shopId) ;
}
