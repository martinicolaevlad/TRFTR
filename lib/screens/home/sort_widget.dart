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
  String _selectedSort = 'latest';
  late final MyShop shop;

  _SortButtonsWidgetState(this.shop);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            buttonPadding: EdgeInsets.symmetric(horizontal: 5),
            children: <Widget>[
              buildSortButton('latest'),
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
          if(_selectedSort == "latest"){
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
        side: BorderSide(color: Colors.red.shade900, width: 1),
        padding: EdgeInsets.symmetric(vertical: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    )
    ;
  }
}
