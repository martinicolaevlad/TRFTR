part of 'create_shop_bloc.dart';

sealed class CreateShopEvent extends Equatable {
  const CreateShopEvent();

  @override
  List<Object> get props => [];
}

class CreateShop extends CreateShopEvent {
  final MyShop shop;
  const CreateShop(this.shop);
}
