import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_repository/shop_repository.dart';

import '../../blocs/rating_bloc/rating_bloc.dart';

class SortButtonsWidget extends StatefulWidget {
  final MyShop shop;

  const SortButtonsWidget({
    required this.shop,
    super.key,
});
  @override
  _SortButtonsWidgetState createState() => _SortButtonsWidgetState(shop);
}

class _SortButtonsWidgetState extends State<SortButtonsWidget> {
  String _selectedSort = 'newest';
  late final MyShop shop;

  _SortButtonsWidgetState(this.shop); // Default selected sort

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          ButtonBar(
            alignment: MainAxisAlignment.center, // Center the buttons within the button bar
            buttonPadding: EdgeInsets.symmetric(horizontal: 5), // Spacing between the buttons
            children: <Widget>[
              buildSortButton('newest'),
              buildSortButton('best'),
              buildSortButton('worst'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSortButton(String title) {
    bool isActive = _selectedSort == title;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedSort = title;
          if(_selectedSort == "newest"){
            context.read<RatingBloc>().add(LoadRatings(widget.shop.id, 'newest'));
          }
          if(_selectedSort == "best"){
            context.read<RatingBloc>().add(LoadRatings(widget.shop.id, 'best'));
          }
          if(_selectedSort == "worst"){
            context.read<RatingBloc>().add(LoadRatings(widget.shop.id, 'worst'));
          }
        });
      },
      child: Text(title),
      style: ElevatedButton.styleFrom(
        foregroundColor: isActive ? Colors.white : Colors.black,
        backgroundColor: isActive ? Colors.red.shade900 : Colors.white,
        side: BorderSide(color: Colors.red.shade900, width: 1), // Border color and width
        padding: EdgeInsets.symmetric(vertical: 4.0), // Adjust vertical padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Adjust border radius if needed
        ),
      ),
    )
    ;
  }
}
