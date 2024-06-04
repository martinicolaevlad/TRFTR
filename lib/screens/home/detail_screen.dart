
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../blocs/my_user_bloc/my_user_bloc.dart';
import '../../blocs/rating_bloc/rating_bloc.dart';

class DetailScreen extends StatefulWidget {
  final MyShop shop;
  final MyUser user;
  const DetailScreen({
    required this.shop,
    required this.user,
    Key? key
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  late final FavoriteRepo _favoriteRepo;
  late final ShopRepo _shopRepo;
  late final RatingRepo _ratingRepo;
  late int displayedRating = 0;


  @override
  void initState() {
    super.initState();
    _favoriteRepo = FirebaseFavoriteRepo();
    _shopRepo = FirebaseShopRepo();
    _ratingRepo = FirebaseRatingRepo();
    _checkFavoriteStatus();
    fetchAndDisplayRating();
    context.read<RatingBloc>().add(LoadRatings(widget.shop.id));
  }

  void fetchAndDisplayRating() async {
    int newRating = 5;
    setState(() {
      displayedRating = newRating;
    });
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
                            : const AssetImage('assets/images/default_shop.jpg') as ImageProvider,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '${displayedRating}/5',
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
                        Container(
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
                mainAxisAlignment: MainAxisAlignment.start, // Center the row within the container
                children: [
                  Text("Sort by:", style: TextStyle(fontSize: 15),),
                  SortButtonsWidget(shop: widget.shop,), // Call the newly created widget here
                ],
              ),
            ),
            Container(
              height: 200,
              child: BlocBuilder<RatingBloc, RatingState>(
                builder: (context, state) {
                  if (state is RatingsLoaded) {
                    log("perfect");
                    return Expanded(
                      child: ListView.builder(
                        itemCount: state.ratings.length,
                        itemBuilder: (context, index) {
                          final rating = state.ratings[index];
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
                              title: Text("Vlad"),
                              subtitle: Text(rating.review),
                              trailing: Container(
                                width: 40,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Ensure the row takes the minimum space
                                  children: [
                                    Text(rating.rating.toString(), style: TextStyle(color: Colors.orangeAccent, fontSize: 17)),
                                    Icon(Icons.star, color: Colors.orangeAccent),
                                  ],
                                ),
                              ),
                            ),
                          );

                        },
                      ),
                    );
                  } else if (state is RatingLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    // Handle other states like error or empty data
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

  // Future<void> _updateAverageRating(String shopId) async {
  //   try {
  //     await Future.delayed(const Duration(hours: 1));
  //     log("Au trecut 5 secunde");
  //      int newRating = await modifyRating(widget.shop);
  //
  //     _shopRepo.getShopById(widget.shop.id).then((existingRating) {
  //       BlocProvider.of<UpdateShopBloc>(context).add(UpdateShop(
  //           shopId: widget.shop.id,
  //           name: widget.shop.name,
  //           latitude: widget.shop.latitude,
  //           longitude: widget.shop.longitude,
  //           nextDrop: widget.shop.nextDrop,
  //           openTime: widget.shop.openTime,
  //           closeTime: widget.shop.closeTime,
  //           ownerId: widget.user.id,
  //           details: widget.shop.details,
  //           rating: displayedRating,
  //           ratingsCount: widget.shop.ratingsCount
  //       ));
  //       BlocProvider.of<GetShopBloc>(context).add(GetShop());
  //       });
  //
  //   } catch (e) {
  //     log('Error updating average rating for shopId $shopId: ${e.toString()}');
  //     rethrow;
  //   }
  // }


  void _launchGoogleMaps(String lat, String long) async {
    String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&destination=$lat,$long&travelmode=driving";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

}
