import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shop_repository/shop_repository.dart';

import '../../blocs/shop_blocs/get_shop_bloc.dart';
import '../../interactive_maps_marker.dart';

class Home extends StatelessWidget {
final List<MarkerItem> markers = [];

  // const Home({super.key});

@override
Widget build(BuildContext context) {
  return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 12.0),

      child: BlocBuilder<GetShopBloc, GetShopState>(
      builder: (context, state) {
        log(state.toString());
        if(state is GetShopSuccess){

          // Clear existing markers
          markers.clear();
          log(state.props[0].toString());
          // Add markers from state.props
          for (var i = 0; i < state.props.length; i++) {
            var prop = state.props[i];
            if (prop is MyShop) {
              double parsedLatitude = double.tryParse(prop.latitude) ?? 0.0;
              double parsedLongitude = double.tryParse(prop.longitude) ?? 0.0;
              markers.add(
                MarkerItem(
                  id: prop.hashCode, // Using hashcode as unique id
                  latitude: parsedLatitude,
                  longitude: parsedLongitude,
                ),
              );
            }
          }

          return Scaffold(

          body: InteractiveMapsMarker(
            items: markers,
            center: LatLng(46.7706315474, 23.6254758254),
            itemContent: (context, index) {
              MarkerItem item = markers[index];
              return BottomTile(item: item);
            },
          ),
        );
        }
        else if (state is GetShopLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is GetShopFailure) {
          return const Center(
            child: Text("Error: pula mea"), // Display the error message
          );
        } else {
          return const Center(
            child: Text("An error has occured.."),
          );

        }
    },
)
  );
}
}

class BottomTile extends StatelessWidget {
  const BottomTile({required this.item});

  final MarkerItem item;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetShopBloc, GetShopState>(
  builder: (context, state) {
    return Container(
      child: Row(
        children: <Widget>[
          Container(width: 120.0, color: Colors.red,
                    child: Image.asset('assets/lamajole.png'),),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("${item.id}", style: Theme.of(context).textTheme.headlineSmall),
                  Text("${item.latitude} , ${item.longitude}", style: Theme.of(context).textTheme.bodySmall),
                  stars(),
                  Expanded(
                    child: Text('Cras et ante metus. Vivamus dignissim augue sit amet nisi volutpat, vitae tincidunt lacus accumsan. '),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  },
);
  }

  Row stars() {
    return Row(
      children: <Widget>[
        Icon(Icons.star, color: Colors.orangeAccent),
        Icon(Icons.star, color: Colors.orangeAccent),
        Icon(Icons.star, color: Colors.orangeAccent),
        Icon(Icons.star_half, color: Colors.orangeAccent),
        Icon(Icons.star_border, color: Colors.orangeAccent),
        SizedBox(width: 3.0),
        Text('3.5', style: TextStyle(color: Colors.orangeAccent, fontSize: 24.0, fontWeight: FontWeight.w600))
      ],
    );
  }
}
