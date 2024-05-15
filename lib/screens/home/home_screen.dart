import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sh_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:sh_app/screens/home/detail_screen.dart';
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
  final MyShop item;

  const BottomTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, userState) {
          return GestureDetector(
            onTap: () {
              if (userState.user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(shop: item, user: userState.user!),
                  ),
                );
              } else {
                // Optionally handle the case where user is null before navigating
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User information not available"))
                );
              }
            },
            child: buildShopTile(context, item),
          );

      },
    );
  }

  Widget buildShopTile(BuildContext context, MyShop item) {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: 120.0,
            color: Colors.red,
            child: isValidPicture(item.picture)
                ? Image.network(
              item.picture!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(CupertinoIcons.photo, size: 100),
            )
                : Icon(CupertinoIcons.photo, size: 100),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 4,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${item.name}", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(
                            "${(item.openTime / 100).toInt().toString().padLeft(2, '0')}:${(item.openTime % 100).toString().padLeft(2, '0')} - ${(item.closeTime / 100).toInt().toString().padLeft(2, '0')}:${(item.closeTime % 100).toString().padLeft(2, '0')}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10,),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.orangeAccent,),
                              Text("${item.rating}/5", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      Text("${item.details}"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isValidPicture(String? url) {
    return url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;
  }
}

