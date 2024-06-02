
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rating_repository/rating_repository.dart';
import 'package:sh_app/blocs/shop_blocs/get_shop_bloc.dart';
import 'package:sh_app/blocs/shop_blocs/update_shop_bloc.dart';
import 'package:sh_app/screens/home/rating_widget.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_repository/user_repository.dart';
import 'package:favorite_repository/favorite_repository.dart';

import '../../blocs/favorite_bloc/favorite_bloc.dart';
import '../../blocs/my_user_bloc/my_user_bloc.dart';
import '../../blocs/rating_bloc/rating_bloc.dart';
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
  late final TextEditingController _ratingController = TextEditingController();
  late int displayedRating = 0;


  @override
  void initState() {
    super.initState();
    _favoriteRepo = FirebaseFavoriteRepo();
    _shopRepo = FirebaseShopRepo();
    _ratingRepo = FirebaseRatingRepo();
    _checkFavoriteStatus();
    fetchAndDisplayRating();
    context.read<RatingBloc>().add(GetRatingsByShopId(widget.shop.id));
  }

  void fetchAndDisplayRating() async {
    int newRating = await modifyRating(widget.shop);
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
            Hero(
              tag: 'shop_image_${widget.shop.id}',
              child: Container(
                height: 300,
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
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${formatTime(widget.shop.openTime)} - ${formatTime(widget.shop.closeTime)}",
                                style: const TextStyle(fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                '${displayedRating}/5',
                                style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                              ),
                              const Icon(Icons.star_rounded, size: 30, color: Colors.orangeAccent)
                            ],
                          ),
                          if (widget.shop.nextDrop == widget.shop.lastDrop)
                            const Text(
                            'Next Drop: Coming Soon',
                            style: TextStyle(fontSize: 16.0),
                            ),
                          if (widget.shop.nextDrop != widget.shop.lastDrop) Text(
                            'Next Drop: ${formatDate(widget.shop.nextDrop!)}',
                            style: const TextStyle(fontSize: 20.0),
                          ),
                          if (widget.shop.lastDrop != null) Text(
                            'Last Drop: ${formatDate(widget.shop.lastDrop!)}',
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),

              Column(
                children: [
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
                                      starsController: _ratingController,
                                      hintText: "0",
                                      shop: widget.shop,
                                      user: widget.user,
                                        onRatingChanged: (selectedStars) async {
                                        _updateAverageRating(widget.shop.id);
                                        }
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
                  SizedBox(height: 4),
                  Container(
                      width: 120,
                      height: 40,
                      child: FloatingActionButton(
                        onPressed: () => _launchGoogleMaps(widget.shop.latitude, widget.shop.longitude),
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.directions),
                      )
                  )
                ],
              )


              ],
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

  Future<void> _updateAverageRating(String shopId) async {
    try {
      await Future.delayed(const Duration(hours: 1));
      log("Au trecut 5 secunde");
       int newRating = await modifyRating(widget.shop);

      _shopRepo.getShopById(widget.shop.id).then((existingRating) {
        BlocProvider.of<UpdateShopBloc>(context).add(UpdateShop(
            shopId: widget.shop.id,
            name: widget.shop.name,
            latitude: widget.shop.latitude,
            longitude: widget.shop.longitude,
            nextDrop: widget.shop.nextDrop,
            openTime: widget.shop.openTime,
            closeTime: widget.shop.closeTime,
            ownerId: widget.user.id,
            details: widget.shop.details,
            rating: displayedRating,
            ratingsCount: widget.shop.ratingsCount
        ));
        BlocProvider.of<GetShopBloc>(context).add(GetShop());
        });

    } catch (e) {
      log('Error updating average rating for shopId $shopId: ${e.toString()}');
      rethrow;
    }
  }

  Future<int> modifyRating(MyShop shop) async {
    List<Rating?> ratings = await _ratingRepo.getRatingsByShopId(shop.id);
    if (ratings.isNotEmpty) {
      int totalRating = ratings.fold(0, (sum, item) => sum + item!.rating);
      int averageRating = totalRating ~/ ratings.length;

      _updateAverageRating(widget.shop.id);

      return averageRating;
    } else {
      return 0;
    }
  }

  void _launchGoogleMaps(String lat, String long) async {
    String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&destination=$lat,$long&travelmode=driving";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

}
