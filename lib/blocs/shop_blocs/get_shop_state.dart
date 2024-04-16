part of 'get_shop_bloc.dart';


sealed class GetShopState extends Equatable {
  const GetShopState();

  @override
  List<Object> get props => [];
}

final class GetShopInitial extends GetShopState {}

final class GetShopFailure extends GetShopState {}
final class GetShopLoading extends GetShopState {}
final class GetShopSuccess extends GetShopState {
  final List<MyShop> shops;

  const GetShopSuccess(this.shops);

  @override
  List<Object> get props => shops;
}