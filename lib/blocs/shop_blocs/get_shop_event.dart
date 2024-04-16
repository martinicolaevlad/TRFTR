part of 'get_shop_bloc.dart';



sealed class GetShopEvent extends Equatable {
  const GetShopEvent();

  @override
  List<Object> get props => [];
}

class GetShop extends GetShopEvent{}