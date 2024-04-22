part of 'create_shop_bloc.dart';

sealed class CreateShopState extends Equatable{
  const CreateShopState();

  @override
  List<Object> get props => [];
}

final class CreateShopInitial extends CreateShopState {}

final class CreateShopLoading extends CreateShopState {}

final class CreateShopSuccess extends CreateShopState {
  final MyShop shop;
  const CreateShopSuccess(this.shop);
}

final class CreateShopFailure extends CreateShopState {}
