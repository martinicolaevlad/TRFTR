import 'package:equatable/equatable.dart';

import '../../favorite_repository.dart';

class Favorite extends Equatable {
  final String id;
  final String userId;
  final String shopId;

  const Favorite({
    required this.id,
    required this.userId,
    required this.shopId,
  });


  Favorite copyWith({
    String? id,
    String? userId,
    String? shopId,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
    );
  }


  FavoriteEntity toEntity() {
    return FavoriteEntity(
      id: id,
      userId: userId,
      shopId: shopId,
    );
  }

  static Favorite fromEntity(FavoriteEntity entity) {
    return Favorite(
      id: entity.id,
      userId: entity.userId,
      shopId: entity.shopId,
    );
  }

  @override
  List<Object?> get props => [id, userId, shopId];

  @override
  String toString() {
    return 'Favorites: { id: $id, userId: $userId, shopId: $shopId }';
  }
}
