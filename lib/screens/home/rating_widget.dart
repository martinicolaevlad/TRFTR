
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
  final String hintText;
  final MyUser user;
  final MyShop shop;

  const RatingInputWidget({
    required this.hintText,
    required this.shop,
    required this.user,

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
    context.read<RatingBloc>().add(GetRating(widget.shop.id, widget.user.id));
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

  void initializeRatingDetails(Rating? rating) {
    if (rating != null) {
      setState(() {
        _selectedStars = rating.rating;
        _selectedReview.text = rating.review;
      });
    } else {
      setState(() {
        _selectedStars = 0;
        _selectedReview.clear();
      });
    }
  }



  List<Widget> _fillStars(int initialRating) {
    _selectedStars = initialRating;

    return List.generate(5, (index) => IconButton(
      icon: Icon(
        _selectedStars > index ? Icons.star : Icons.star_border,
        color: Colors.orangeAccent,
        size: 30,
      ),
      onPressed: () {
        setState(() {
          _selectedStars = index + 1;
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RatingBloc, RatingState>(
      listener: (context, state) {
        if (state is RatingLoaded) {
          initializeRatingDetails(state.rating);
          log('state is loaded');
        } else if (state is RatingFailure) {
          initializeRatingDetails(null);
          log('state is failure');
        }
      },
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) => IconButton(
                      icon: Icon(
                        _selectedStars > index ? Icons.star : Icons.star_border,
                        color: Colors.orangeAccent,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedStars = index + 1;
                        });
                      },
                    )),
                  ),
                ),
                Text(
                  "${_selectedStars != 0 ? _selectedStars.toString() : widget.hintText}/5",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                  hintText: "Type here your review",
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
                  Container(
                    width: 120,
                    height: 40,
                    child:FloatingActionButton(
                      onPressed: () {
                        if (_validateInputs()) {
                          Rating newRating = Rating(
                            id: '',
                            rating: _selectedStars,
                            review: _selectedReview.text,
                            userId: widget.user.id,
                            shopId: widget.shop.id,
                            time: DateTime.now(),
                          );
                          if(state is RatingFailure){
                            context.read<RatingBloc>().add(AddRating(newRating));
                            // context.read<RatingBloc>().add(LoadRatings(widget.shop.id, 'latest'));
                          }
                          else if (state is RatingLoaded)
                          {
                            log('is aici fac update u');
                            context.read<RatingBloc>().add(UpdateRating(
                              ratingId: state.rating!.id,
                              rating: _selectedStars,
                              review: _selectedReview.text,
                              userId: widget.user.id,
                              shopId: widget.shop.id,
                              time: DateTime.now(),)
                            );
                          }
                          context.read<RatingBloc>().add(LoadRatings(widget.shop.id, 'latest'));
                          Navigator.of(context).pop();
                        }
                      },
                      backgroundColor: Colors.red.shade900,
                      heroTag: 'save_rating_button',
                      child: const Text("Save", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 120,
                    height: 40,
                    child: FloatingActionButton(
                      onPressed: () {
                        context.read<RatingBloc>().add(LoadRatings(widget.shop.id, 'latest'));

                        Navigator.of(context).pop();
                      },
                      backgroundColor: Colors.white,
                      heroTag: 'cancel_rating_button',
                      child: Text("Cancel", style: TextStyle(color: Colors.red.shade900)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

}
