import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class FavoriteEntity extends Equatable {
  final String id;
  final String userId;
  final String shopId;

  const FavoriteEntity({
    required this.id,
    required this.userId,
    required this.shopId,
  });

  @override
  List<Object?> get props => [id, userId, shopId];

  @override
  String toString() {
    return 'FavoritesEntity: { id: $id, userId: $userId, shopId: $shopId }';
  }

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'userId': userId,
      'shopId': shopId,
    };
  }

  static FavoriteEntity fromDocument(Map<String, dynamic> doc) {
    return FavoriteEntity(
      id: doc['id'] as String,
      userId: doc['userId'] as String,
      shopId: doc['shopId'] as String,
    );
  }
}
