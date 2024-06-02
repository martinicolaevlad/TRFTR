
import 'dart:developer';

import 'package:flutter/cupertino.dart';
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
  TextEditingController _selectedReview = TextEditingController();
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
        _selectedReview.text = fetchedRating.review;
        _fillStars();
      });
    }
  }

  List<Widget> _fillStars() {
    return List.generate(5, (index) => IconButton(
      icon: Icon(
        _selectedStars > index ? Icons.star : Icons.star_border,
        color: Colors.orangeAccent,
        size: 30,
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
      showErrorDialog('Please touch a star.');
      return false;
    }
    if (_selectedReview == '') {
      showErrorDialog('Please type a review.');
      return false;
    }

    return true;
  }

  void _saveRatingDetails() async {
    if (!_validateInputs()) {
      return;
    }

    _ratingRepo.getRating(widget.user.id, widget.shop.id).then((existingRating) {

      if (existingRating != null) {
        BlocProvider.of<RatingBloc>(context).add(UpdateRating(
            ratingId: existingRating.id,
            userId: existingRating.userId,
            shopId: existingRating.shopId,
            rating: _selectedStars,
            review: _selectedReview.text,
            time: DateTime.now()
        ));

      } else {

        BlocProvider.of<RatingBloc>(context).add(AddRating(
            Rating(
                id: "0",
                userId: user.id,
                shopId: shop.id,
                rating: _selectedStars,
                review: _selectedReview.text,
                time: DateTime.now()
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _fillStars()
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
          ],
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _selectedReview,
            maxLength: 150,
            keyboardType: TextInputType.multiline,
            maxLines: 6,
            minLines: 1,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "type here your review",
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
               Container(
                 width: 120,
                 height: 40,
                 child: FloatingActionButton(
                    onPressed: () {
                      _saveRatingDetails();
                      Navigator.of(context).pop();
                    },
                   backgroundColor: Colors.red.shade900,
                   heroTag: 'rating_button',
                   child: const Text("Save", style: TextStyle(color: Colors.white),),
                  ),
               ),
              const SizedBox(width: 5),
              Container(
                width: 120,
                height: 40,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  backgroundColor: Colors.white,
                  heroTag: 'rating_button',
                  child: Text("Cancel", style: TextStyle(color: Colors.red.shade900),),
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
