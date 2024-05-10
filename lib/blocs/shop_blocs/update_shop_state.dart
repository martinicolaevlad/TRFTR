part of 'update_shop_bloc.dart';

abstract class UpdateShopState extends Equatable {
  const UpdateShopState();

  @override
  List<Object> get props => [];
}

class UpdateShopInitial extends UpdateShopState {}

class UpdateShopLoading extends UpdateShopState {}

class UpdateShopSuccess extends UpdateShopState {
  final MyShop shop;
  const UpdateShopSuccess(this.shop);

  @override
  List<Object> get props => [shop];
}

class UpdateShopFailure extends UpdateShopState {}
