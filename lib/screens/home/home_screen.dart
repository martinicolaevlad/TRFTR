import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sh_app/screens/home/detail_screen.dart';
import 'package:sh_app/screens/search/search_screen.dart';
import 'package:shop_repository/shop_repository.dart';

import '../../blocs/shop_blocs/get_shop_bloc.dart';
import '../../interactive_maps_marker.dart';

class Home extends StatelessWidget {
final List<MarkerItem> markers = [];

  // const Home({super.key});

@override
Widget build(BuildContext context) {
  return Padding(

      padding: EdgeInsets.zero,

      child: BlocBuilder<GetShopBloc, GetShopState>(
      builder: (context, state) {
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
              var prop = state.props[index];
              if (prop is MyShop){
                MyShop item = prop; return BottomTile(item: item);}
              return const Text('error');

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
            child: Text("GET SHOP FAILURE"), // Display the error message
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

  final MyShop item;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetShopBloc, GetShopState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(shop: item), // Replace NewScreen with the actual screen class you want to navigate to
              ),
            );
          },
          child: Container(
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  color: Colors.red,
                  child: Image.asset('assets/lamajole.png'),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${item.name}", style: Theme.of(context).textTheme.headlineSmall),
                        Text(
                          "${(item.openTime / 100).toInt().toString().padLeft(2, '0')}:${(item.openTime % 100).toString().padLeft(2, '0')} - ${(item.closeTime / 100).toInt().toString().padLeft(2, '0')}:${(item.closeTime % 100).toString().padLeft(2, '0')}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        stars(item),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Row stars(MyShop item) {
  List<Widget> starIcons = [];
  int filledStars = item.rating ~/ 1;
  for (int i = 0; i < filledStars; i++) {
    starIcons.add(Icon(Icons.star, color: Colors.orangeAccent));
  }
  if (item.rating % 1 > 0) {
    starIcons.add(Icon(Icons.star_half, color: Colors.orangeAccent));
    filledStars++;
  }
  for (int i = filledStars; i < 5; i++) {
    starIcons.add(Icon(Icons.star_border, color: Colors.orangeAccent));
  }

  starIcons.add(SizedBox(width: 3.0));
  starIcons.add(Text(
    '${item.rating}',
    style: TextStyle(color: Colors.orangeAccent, fontSize: 24.0, fontWeight: FontWeight.w600),
  ));

  return Row(children: starIcons);
}


