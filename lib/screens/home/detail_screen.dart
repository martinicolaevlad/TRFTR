import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:favorite_repository/favorite_repository.dart';

import '../../blocs/favorite_bloc/favorite_bloc.dart';
import '../../blocs/my_user_bloc/my_user_bloc.dart'; // Assuming this is the correct path

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
  bool isFavorite = false;  // Placeholder for favorite state
  late final FavoriteRepo _favoriteRepo;

  @override
  void initState() {
    super.initState();
    _favoriteRepo = FirebaseFavoriteRepo();
    _checkFavoriteStatus();
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
      appBar: AppBar(
        title: Text(widget.shop.name, style: Theme.of(context).textTheme.displaySmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rating: ${widget.shop.rating}',
                        style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Hours: ${formatTime(widget.shop.openTime)} - ${formatTime(widget.shop.closeTime)}",
                        style: const TextStyle(fontSize: 18.0, color: Colors.grey),
                      ),
                      if (widget.shop.nextDrop != null) Text(
                        'Next Drop: ${formatDate(widget.shop.nextDrop!)}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      if (widget.shop.lastDrop != null) Text(
                        'Last Drop: ${formatDate(widget.shop.lastDrop!)}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      // Add more details as needed
                    ],
                  ),
                  Spacer(),
                  FloatingActionButton(
                    onPressed: _toggleFavorite,
                    backgroundColor: Colors.red,
                    child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  ),
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
}
