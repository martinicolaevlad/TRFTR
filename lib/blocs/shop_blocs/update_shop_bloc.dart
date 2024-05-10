import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'update_shop_event.dart';
part 'update_shop_state.dart';

class UpdateShopBloc extends Bloc<UpdateShopEvent, UpdateShopState> {
  final ShopRepo _shopRepo;

  UpdateShopBloc({
    required ShopRepo shopRepo,
  }) : _shopRepo = shopRepo,
        super(UpdateShopInitial()) {
    on<UpdateShop>((event, emit) async {
      emit(UpdateShopLoading());
      try {
        MyShop updatedShop = await _shopRepo.updateShopDetails(
          event.shopId,
          name: event.name,
          rating: event.rating,
          picture: event.picture,
          nextDrop: event.nextDrop,
          lastDrop: event.lastDrop,
          latitude: event.latitude,
          longitude: event.longitude,
          openTime: event.openTime,
          closeTime: event.closeTime,
          ownerId: event.ownerId,
          details: event.details
        );
        emit(UpdateShopSuccess(updatedShop));
      } catch (e) {
        emit(UpdateShopFailure());
      }
    });
  }
}
