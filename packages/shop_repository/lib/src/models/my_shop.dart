
import 'package:equatable/equatable.dart';

import '../../shop_repository.dart';


class MyShop extends Equatable {
  final String id;
  final String name;
  final int rating;
  final String? picture;
  final DateTime? nextDrop;
  final DateTime? lastDrop;
  final String latitude;
  final String longitude;
  final int openTime;
  final int closeTime;
  final String? ownerId;

  const MyShop({
    required this.id,
    required this.name,
    required this.rating,
    this.picture,
    this.nextDrop,
    this.lastDrop,
    required this.latitude,
    required this.longitude,
    required this.openTime,
    required this.closeTime,
    this.ownerId,
  });

  static final empty = MyShop(
      id: '',
      name: '',
      rating: 0,
      picture: '',
      nextDrop: DateTime.now(),
      lastDrop: DateTime.now(),
      latitude: '',
      longitude: '',
      openTime: 0,
      closeTime: 0,
      ownerId: ''
  );

  MyShop copyWith({
    String? id,
    String? name,
    int? rating,
    String? picture,
    DateTime? nextDrop,
    DateTime? lastDrop,
    String? latitude,
    String? longitude,
    int? openTime,
    int? closeTime,
    String? ownerId,
  }) {
    return MyShop(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      picture: picture ?? this.picture,
      nextDrop: nextDrop ?? this.nextDrop,
      lastDrop: lastDrop ?? this.lastDrop,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      ownerId: ownerId ?? this.ownerId,
    );
  }


  bool get isEmpty => this == MyShop.empty;
  bool get isNotEmpty => this != MyShop.empty;

  MyShopEntity toEntity() {
    return MyShopEntity(
      id: id,
      name: name,
      rating: rating,
      picture: picture,
      nextDrop: nextDrop,
      lastDrop: lastDrop,
      latitude: latitude,
      longitude: longitude,
      openTime: openTime,
      closeTime: closeTime,
      ownerId: ownerId,
    );
  }

  static MyShop fromEntity(MyShopEntity entity) {
    return MyShop(
      id: entity.id,
      name: entity.name,
      rating: entity.rating,
      picture: entity.picture,
      nextDrop: entity.nextDrop,
      lastDrop: entity.lastDrop,
      latitude: entity.latitude,
      longitude: entity.longitude,
      openTime: entity.openTime,
      closeTime: entity.closeTime,
      ownerId: entity.ownerId,
    );
  }

  @override
  List<Object?> get props => [id, name, rating, picture, nextDrop, lastDrop, latitude, longitude, openTime, closeTime, ownerId];
}
