import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sh_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:sh_app/screens/home/detail_screen.dart';
import 'package:shop_repository/shop_repository.dart';
import '../../blocs/map_bloc/map_bloc.dart';
import '../../blocs/shop_blocs/get_shop_bloc.dart';
import '../../interactive_maps_marker.dart';

class Home extends StatefulWidget {
  final PersistentTabController controller;

  Home({super.key, required this.controller});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<MarkerItem> markers = [];
  final TextEditingController _searchController = TextEditingController();
  GlobalKey<InteractiveMapsMarkerState> mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        if (state is ShopSelected) {
          final mapState = mapKey.currentState;
          mapState?.focusOnSelectedShop(state.shopId);
        }
      },
      child: Container(
        child: Padding(
          padding: EdgeInsets.zero,
          child: BlocBuilder<GetShopBloc, GetShopState>(
            builder: (context, state) {
              if (state is GetShopSuccess) {
                markers.clear();
                state.shops.forEach((shop) {
                  double parsedLatitude = double.tryParse(shop.latitude) ?? 0.0;
                  double parsedLongitude = double.tryParse(shop.longitude) ?? 0.0;
                  markers.add(
                    MarkerItem(
                      id: shop.id,
                      latitude: parsedLatitude,
                      longitude: parsedLongitude,
                    ),
                  );
                });
                return Scaffold(
                  body: Stack(
                    children: [
                      InteractiveMapsMarker(
                        key: mapKey,
                        items: markers,
                        center: const LatLng(46.7706315474, 23.6254758254),
                        itemContent: (context, index) {
                          MyShop item = state.shops[index];
                          return BottomTile(item: item, controller: widget.controller);
                        },
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: _buildSearchField(),
                          ),

                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return state is GetShopLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const Center(child: Text("Failed to load shops"));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: "Search...",
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),

      ],
    );
  }
}

class BottomTile extends StatelessWidget {
  final MyShop item;
  final PersistentTabController controller;
  const BottomTile({super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, userState) {
        return GestureDetector(
          onTap: () {
            if (userState.user != null) {
              log("Shop: $item, User: ${userState.user}, Controller: $controller");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(shop: item, user: userState.user!, controller: controller),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User information not available")),
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
        children: [
          Container(
            height: double.infinity,
            width: 120.0,
            color: Colors.red.shade900,
            child: isValidPicture(item.picture)
                ? Image.network(
              item.picture!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(CupertinoIcons.photo, size: 100),
            )
                : const Icon(CupertinoIcons.photo, size: 100),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text(
                        "${(item.openTime ~/ 100).toString().padLeft(2, '0')}:${(item.openTime % 100).toString().padLeft(2, '0')} - ${(item.closeTime ~/ 100).toString().padLeft(2, '0')}:${(item.closeTime % 100).toString().padLeft(2, '0')}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orangeAccent),
                          Text("${item.rating}/5", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  Text("${item.details}"),
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
