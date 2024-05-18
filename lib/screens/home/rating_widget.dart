
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rating_repository/rating_repository.dart';
import 'package:sh_app/blocs/shop_blocs/get_shop_bloc.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/rating_bloc/rating_bloc.dart';
import '../../blocs/shop_blocs/update_shop_bloc.dart';

class RatingInputWidget extends StatefulWidget {
  final TextEditingController starsController;
  final String hintText;
  final MyUser user;
  final MyShop shop;
  final Function(int) onRatingChanged;

  const RatingInputWidget({
    required this.starsController,
    required this.hintText,
    required this.shop,
    required this.user,
    required this.onRatingChanged,

    super.key,
  });

  @override
  _RatingInputWidgetState createState() => _RatingInputWidgetState(user, shop);
}

class _RatingInputWidgetState extends State<RatingInputWidget> {
  late final MyUser user;
  late final MyShop shop;
  int _selectedStars = 0;
  Rating? rating;
  final FirebaseRatingRepo _ratingRepo = FirebaseRatingRepo();
  _RatingInputWidgetState(this.user, this.shop);

  @override
  void initState() {
    super.initState();
    initializeRatingDetails();
  }

  int newRating(int rating, int counter) {
    if(counter != 0) {
      return (rating * counter + _selectedStars) ~/ (counter + 1);
    }
    return _selectedStars;
  }

  int modifyRating(int rating, int counter, int oldRating){
    int newValue = (rating * counter - oldRating + _selectedStars)~/(counter);
    return newValue;
  }

  void initializeRatingDetails() async {
    var fetchedRating = await _ratingRepo.getRating(widget.user.id, widget.shop.id);
    if (fetchedRating != null) {
      setState(() {
        rating = fetchedRating;
        _selectedStars = fetchedRating.rating;
        _fillStars();
      });
    }
  }

  List<Widget> _fillStars() {
    return List.generate(5, (index) => IconButton(
      icon: Icon(
        _selectedStars > index ? Icons.star : Icons.star_border,
        color: Colors.orangeAccent,
        size: 40,
      ),
      onPressed: () {
        setState(() {
          _selectedStars = index + 1;
          widget.starsController.text = _selectedStars.toString();
          widget.onRatingChanged(_selectedStars);
        });
      },
    ));
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  bool _validateInputs() {
    if (_selectedStars == 0) {
      showErrorDialog('Please enter the shop name.');
      return false;
    }
    return true;
  }

  void _saveRatingDetails() async {
    if (!_validateInputs()) {
      return;
    }

    _ratingRepo.getRating(widget.user.id, widget.shop.id).then((existingRating) {
      log("Inainte:");
      log("rating" +shop.rating.toString());
      log("counter" +shop.ratingsCount.toString());

      if (existingRating != null) {
        // int oldRating = existingRating.rating;
        BlocProvider.of<RatingBloc>(context).add(UpdateRating(
            ratingId: existingRating.id,
            userId: existingRating.userId,
            shopId: existingRating.shopId,
            rating: _selectedStars
        ));

        // var updateShop = UpdateShop(
        //     shopId: shop.id,
        //     name: shop.name,
        //     latitude: shop.latitude,
        //     longitude: shop.longitude,
        //     nextDrop: shop.nextDrop,
        //     openTime: shop.openTime,
        //     closeTime: shop.closeTime,
        //     ownerId: user.id,
        //     details: shop.details,
        //     rating: modifyRating(
        //         shop.rating, shop.ratingsCount, oldRating),
        //     ratingsCount: shop.ratingsCount
        // );
        // BlocProvider.of<UpdateShopBloc>(context).add(updateShop);
        // BlocProvider.of<GetShopBloc>(context).add(GetShop());


      } else {

        BlocProvider.of<RatingBloc>(context).add(AddRating(
            Rating(
                id: "0",
                userId: user.id,
                shopId: shop.id,
                rating: _selectedStars
            )));
        BlocProvider.of<UpdateShopBloc>(context).add(UpdateShop(
            shopId: shop.id,
            name: shop.name,
            latitude: shop.latitude,
            longitude: shop.longitude,
            nextDrop: shop.nextDrop,
            openTime: shop.openTime,
            closeTime: shop.closeTime,
            ownerId: user.id,
            details: shop.details,
            rating: shop.rating,
            ratingsCount: shop.ratingsCount + 1
        ));
      }

      BlocProvider.of<GetShopBloc>(context).add(GetShop());
    }
    );}
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _fillStars(),
          ),
        ),
        Text(
          "${widget.starsController.text.isNotEmpty
              ? widget.starsController.text
              : rating != null ? rating!.rating : widget.hintText}/5",
          style: const TextStyle(color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    _saveRatingDetails();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  child: const Text('Rate'),
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 20),

            ],
          ),
        ),
      ],
    );
  }
}
