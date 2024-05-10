

part of 'update_shop_bloc.dart';

abstract class UpdateShopEvent extends Equatable {
  const UpdateShopEvent();

  @override
  List<Object?> get props => [];
}

class UpdateShop extends UpdateShopEvent {
  final String shopId;
  final String? name;
  final int? rating;
  final String? picture;
  final DateTime? nextDrop;
  final DateTime? lastDrop;
  final String? latitude;
  final String? longitude;
  final int? openTime;
  final int? closeTime;
  final String? ownerId;
  final String? details;

  const UpdateShop({
    required this.shopId,
    this.name,
    this.rating,
    this.picture,
    this.nextDrop,
    this.lastDrop,
    this.latitude,
    this.longitude,
    this.openTime,
    this.closeTime,
    this.ownerId,
    this.details
  });

  @override
  List<Object?> get props => [shopId, name, rating, picture, nextDrop, lastDrop, latitude, longitude, openTime, closeTime, ownerId, details];
}
