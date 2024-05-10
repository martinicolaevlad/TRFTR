import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MyShopEntity extends Equatable {
  final String id;
  final String name;
  final int rating; // Rating as integer
  final String? picture;
  final DateTime? nextDrop; // Using DateTime for drop times
  final DateTime? lastDrop; // Using DateTime for drop times
  final String latitude;
  final String longitude;
  final int openTime; // Store open time as an integer (e.g., 900 for 9:00 AM)
  final int closeTime; // Store close time as an integer (e.g., 1700 for 5:00 PM)
  final String? ownerId;
  final String? details; // Additional details about the shop

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
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'picture': picture,
      'nextDrop': nextDrop?.toIso8601String(),
      'lastDrop': lastDrop?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'openTime': openTime,
      'closeTime': closeTime,
      'ownerId': ownerId,
      'details': details,
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
    );
  }

  @override
  List<Object?> get props => [
    id, name, rating, picture, nextDrop, lastDrop, latitude, longitude, openTime, closeTime, ownerId, details
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
      details: $details
    }''';
  }
}
