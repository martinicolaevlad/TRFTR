import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_repository/shop_repository.dart';

part 'get_shop_event.dart';
part 'get_shop_state.dart';

class GetShopBloc extends Bloc<GetShopEvent, GetShopState> {
  final ShopRepo _shopRepo;

  GetShopBloc(this._shopRepo) : super(GetShopInitial()) {
    on<GetShop>((event, emit) async {
      emit(GetShopLoading());
      try {
        List<MyShop> shops = await _shopRepo.getShops();
        emit(GetShopSuccess(shops));
      } catch (e) {
        emit(GetShopFailure());
      }
    });
  }
}