import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MyShopEntity extends Equatable {
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
  final String? details;
  final int ratingsCount;

  const MyShopEntity({
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

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'picture': picture,
      'nextDrop': nextDrop,
      'lastDrop': lastDrop,
      'latitude': latitude,
      'longitude': longitude,
      'openTime': openTime,
      'closeTime': closeTime,
      'ownerId': ownerId,
      'details': details,
      'ratingsCount': ratingsCount
    };
  }

  static MyShopEntity fromDocument(Map<String, dynamic> doc) {
    return MyShopEntity(
      id: doc['id'] as String,
      name: doc['name'] as String,
      rating: (doc['rating'] ?? 0) as int,
      picture: doc['picture'] as String?,
      nextDrop: (doc['nextDrop'] as Timestamp).toDate(),
      lastDrop: (doc['lastDrop'] as Timestamp).toDate(),
      latitude: doc['latitude'] as String,
      longitude: doc['longitude'] as String,
      openTime: (doc['openTime'] ?? 0) as int,
      closeTime: (doc['closeTime'] ?? 0) as int,
      ownerId: doc['ownerId'] as String?,
      details: doc['details'] as String?,
        ratingsCount: doc['ratingsCount'] as int
    );
  }

  @override
  List<Object?> get props => [
    id, name, rating, picture, nextDrop, lastDrop, latitude, longitude, openTime, closeTime, ownerId, details, ratingsCount
  ];

  @override
  String toString() {
    return '''ShopEntity: {
      id: $id,
      name: $name,
      rating: $rating,
      picture: $picture,
      nextDrop: $nextDrop,
      lastDrop: $lastDrop,
      latitude: $latitude,
      longitude: $longitude,
      openTime: $openTime,
      closeTime: $closeTime,
      ownerId: $ownerId,
      details: $details,
      ratingsCount: $ratingsCount
    }''';
  }
}
