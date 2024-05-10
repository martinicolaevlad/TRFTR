import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'create_shop_event.dart';
part 'create_shop_state.dart';


class CreateShopBloc extends Bloc<CreateShopEvent, CreateShopState> {
  ShopRepo _shopRepo;
  CreateShopBloc({
    required ShopRepo shopRepo
}) : _shopRepo = shopRepo,
      super(CreateShopInitial()){
    on<CreateShop>((event,emit) async{
      emit(CreateShopLoading());
      try{
        MyShop shop = await _shopRepo.createShop(event.shop);
        emit(CreateShopSuccess(shop));
      } catch (e) {
        emit(CreateShopFailure());
      }
    });
  }
}
