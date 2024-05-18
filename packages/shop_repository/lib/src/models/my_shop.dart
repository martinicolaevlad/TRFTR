
import 'package:equatable/equatable.dart';

import '../../shop_repository.dart';


class MyShop extends Equatable {
  String id;
  String name;
  int rating;
  String? picture;
  DateTime? nextDrop;
  DateTime? lastDrop;
  String latitude;
  String longitude;
  int openTime;
  int closeTime;
  String? ownerId;
  String? details;
  int ratingsCount;

  MyShop({
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
    this.details,
    required this.ratingsCount
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
      ownerId: '',
      details: '',
      ratingsCount: 0
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
    String? details,
    int? ratingsCount
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
      details: details ?? this.details,
        ratingsCount: ratingsCount ?? this.ratingsCount
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
      details: details,
        ratingsCount: ratingsCount
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
      details: entity.details,
        ratingsCount: entity.ratingsCount
    );
  }

  @override
  List<Object?> get props => [id, name, rating, picture, nextDrop, lastDrop, latitude, longitude, openTime, closeTime, ownerId, details, ratingsCount];
}
