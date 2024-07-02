
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:rating_repository/rating_repository.dart';
import 'package:sh_app/blocs/shop_blocs/get_shop_bloc.dart';
import 'package:sh_app/blocs/shop_blocs/update_shop_bloc.dart';
import 'package:sh_app/screens/home/rating_widget.dart';
import 'package:sh_app/screens/home/sort_widget.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_repository/user_repository.dart';
import 'package:favorite_repository/favorite_repository.dart';

import '../../blocs/favorite_bloc/favorite_bloc.dart';
import '../../blocs/map_bloc/map_bloc.dart';
import '../../blocs/my_user_bloc/my_user_bloc.dart';
import '../../blocs/rating_bloc/rating_bloc.dart';
import 'home_screen.dart';

class DetailScreen extends StatefulWidget {
  final MyShop shop;
  final MyUser user;
  final PersistentTabController controller;

  const DetailScreen({
    required this.shop,
    required this.user,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  late final FavoriteRepo _favoriteRepo;
  late final ShopRepo _shopRepo;
  late final RatingRepo _ratingRepo;

  @override
  void initState() {
    super.initState();
    _favoriteRepo = FirebaseFavoriteRepo();
    _shopRepo = FirebaseShopRepo();
    _ratingRepo = FirebaseRatingRepo();
    _checkFavoriteStatus();
    context.read<RatingBloc>().add(LoadRatings(widget.shop.id, 'latest'));
  }


  Future<void> _checkFavoriteStatus() async {
    var favorite = await _favoriteRepo.getFavorite(widget.user.id, widget.shop.id);
    setState(() {
      isFavorite = favorite != null;
    });
  }


  void _toggleFavorite() async {
    if (isFavorite) {
      await _favoriteRepo.deleteFavorite(widget.user.id, widget.shop.id);
    } else {
      await _favoriteRepo.createFavorite(widget.user.id, widget.shop.id);
    }
    BlocProvider.of<FavoritesBloc>(context).add(LoadUserFavorites(context.read<MyUserBloc>().state.user!.id));
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,

      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.shop.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
            color: Colors.red.shade900,
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(width: 1, color: Colors.grey.shade400), bottom: BorderSide(width: 1, color: Colors.grey.shade400),),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: isValidPicture(widget.shop.picture)
                            ? NetworkImage(widget.shop.picture!)
                            : const AssetImage('assets/2.png') as ImageProvider,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      children: [

                        Container(
                          width: 120,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),

                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${widget
                                    .shop.rating}/5',
                                    style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                                  ),
                                  const Icon(Icons.star_rounded, size: 30, color: Colors.orangeAccent)
                                ],
                              ),
                              Text(
                                formatTime(widget.shop.openTime),
                                style: const TextStyle(fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.access_time_filled_rounded),
                              Text(
                                formatTime(widget.shop.closeTime),
                                style: const TextStyle(fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        SizedBox(
                          width: 120,
                          height: 40,
                          child:FloatingActionButton(
                            onPressed: () {
                              context.read<MapBloc>().add(SelectShopOnMap(widget.shop.id, widget.shop.latitude, widget.shop.longitude));
                              widget.controller.jumpToTab(0);
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            backgroundColor: Colors.green.shade500,
                            heroTag: 'to_map_button',
                            child: const Text("See on map", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 5),
                          SizedBox(
                          width: 120,
                          height: 40,
                          child: FloatingActionButton(
                            onPressed: () {
                              try {
                                final updateShopBloc = BlocProvider.of<UpdateShopBloc>(context);
                                final getShopBloc = BlocProvider.of<GetShopBloc>(context);
                                final ratingBloc = BlocProvider.of<RatingBloc>(context);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return MultiBlocProvider(
                                        providers: [
                                          BlocProvider.value(
                                            value: updateShopBloc,
                                          ),
                                          BlocProvider.value(
                                            value: getShopBloc,
                                          ),
                                          BlocProvider.value(
                                            value: ratingBloc,
                                          )
                                        ],
                                        child: Dialog(
                                          child: RatingInputWidget(
                                            hintText: "0",
                                            shop: widget.shop,
                                            user: widget.user,
                                          ),
                                        ),
                                      );
                                    }
                                );
                              } catch (e) {
                                log('Bloc is not available in the current context: $e');
                              }
                            },
                            backgroundColor: Colors.red.shade900,
                            heroTag: 'rating_button',
                            child: Text("Rate & review", style: TextStyle(color: Colors.white),),

                          ),
                        ),

                    ],),
                  ),
                )
              ],
            ),

            Divider(height: 1, color: Colors.grey.shade400,),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Center(child: Text(widget.shop.details ?? "Welcome to our shop!",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
            ),
            Divider(height: 1, color: Colors.grey.shade400,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Sort by:", style: TextStyle(fontSize: 17),),
                  SortButtonsWidget(shop: widget.shop,),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade400,),
            Container(
              height: 200,
              child: BlocBuilder<RatingBloc, RatingState>(
                builder: (context, state) {
                  if (state is RatingsLoaded) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: state.ratingsWithUser.length,
                        itemBuilder: (context, index) {
                          final rating = state.ratingsWithUser[index].rating;
                            return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        SizedBox(width: 70, child: Text(state.ratingsWithUser[index].userName)),
                                        const SizedBox(width: 10),
                                        Text(
                                          '• ${rating.time.day < 10 ? "0${rating.time.day}" : "${rating.time.day}"}.${rating.time.month < 10 ? "0${rating.time.month}" : "${rating.time.month}"}.${rating.time.year} •',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(rating.review),
                                    trailing: Container(
                                      width: 40,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(rating.rating.toString(), style: TextStyle(color: Colors.orangeAccent, fontSize: 17)),
                                          Icon(Icons.star, color: Colors.orangeAccent),
                                        ],
                                      ),
                                    ),

                                  ),
                                );
                                ;

                        },
                      ),
                    );
                  } else if (state is RatingLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is RatingLoaded) {
                    return Center(child: Text(""),);
                  } else {
                    return Center(child: Text("No reviews available"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isValidPicture(String? url) {
    return url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;
  }

  String formatTime(int time) {
    return '${(time / 100).toInt().toString().padLeft(2, '0')}:${(time % 100).toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }


}
