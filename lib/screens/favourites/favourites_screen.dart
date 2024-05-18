import 'dart:developer';
import 'package:favorite_repository/favorite_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sh_app/blocs/favorite_bloc/favorite_bloc.dart';
import 'package:sh_app/blocs/shop_blocs/get_shop_bloc.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/my_user_bloc/my_user_bloc.dart';
import '../home/home_screen.dart';

class Favourites extends StatefulWidget {
  const Favourites({Key? key}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<MyUserBloc>().state.user!.id;
    context.read<FavoritesBloc>().add(LoadUserFavorites(userId));
  }

  final FirebaseShopRepo _shopRepo = FirebaseShopRepo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Favourites", style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold)),
      ),),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return Center(child: Text('No favorites available'));
            }
            return ListView.builder(
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final favorite = state.favorites[index];
                return FutureBuilder<MyShop?>(
                  future: _shopRepo.getShopById(favorite.shopId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading shop: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(child: Text('Shop not found'));
                    }
                    final shop = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey), // Border color
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                          color: Colors.white
                        ),
                        clipBehavior: Clip.antiAlias,

                        child: SizedBox(
                            height: 120,
                            width: 120,

                            child: BottomTile(item: shop)),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is FavoritesFailure) {
            return Center(child: Text('Failed to load favorites: ${state.runtimeType}'));
          }
          return Center(child: Text('No favorites available'));
        },
      ),
    );
  }
}
