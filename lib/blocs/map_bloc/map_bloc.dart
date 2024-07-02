import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Event class
abstract class MapEvent extends Equatable {
  const MapEvent();
}

class SelectShopOnMap extends MapEvent {
  final String shopId;
  final String latitude;
  final String longitude;

  const SelectShopOnMap(this.shopId, this.latitude, this.longitude);

  @override
  List<Object> get props => [shopId, latitude, longitude];
}

// State class
abstract class MapState extends Equatable {
  const MapState();
}

class MapInitial extends MapState {
  @override
  List<Object> get props => [];
}

class ShopSelected extends MapState {
  final String shopId;
  final String latitude;
  final String longitude;

  const ShopSelected(this.shopId, this.latitude, this.longitude);

  @override
  List<Object> get props => [shopId, latitude, longitude];
}


class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial()) {
    on<SelectShopOnMap>((event, emit) {
      emit(ShopSelected(event.shopId, event.latitude, event.longitude));
    });
  }
}
