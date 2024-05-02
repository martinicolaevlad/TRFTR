import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sh_app/screens/profile/profile_screen.dart';
import 'package:shop_repository/shop_repository.dart';

import '../../blocs/log_in_bloc/log_in_bloc.dart';

class ShopProfileScreen extends StatelessWidget {
  final MyShop shop;

  const ShopProfileScreen({required this.shop, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (shop.picture != null)
              Image.network(
                shop.picture!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16.0),
            Center(child: Text(shop.name, style: Theme.of(context).textTheme.displayMedium,)),

            Text(
              'Rating: ${shop.rating}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              "${(shop.openTime / 100).toInt().toString().padLeft(2, '0')}:${(shop.openTime % 100).toString().padLeft(2, '0')} - ${(shop.closeTime / 100).toInt().toString().padLeft(2, '0')}:${(shop.closeTime % 100).toString().padLeft(2, '0')}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8.0),
            if(shop.nextDrop == DateTime.now())
              const Text(
                'Next Drop: TODAY',
                style: TextStyle(fontSize: 16.0),
              ),
            if (shop.nextDrop != null)
              Text(
                'Next Drop: ${shop.nextDrop?.day}.${shop.nextDrop?.month}.${shop.nextDrop?.year}',
                style: TextStyle(fontSize: 16.0),
              ),
            if (shop.lastDrop != null)
              Text(
                'Last Drop: ${shop.lastDrop?.day}.${shop.lastDrop?.month}.${shop.lastDrop?.year}',
                style: TextStyle(fontSize: 16.0),
              ),
            SizedBox(height: 8.0),
            Text(
              'Location: (${shop.latitude}, ${shop.longitude})',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            // Add more details as needed
            ProfileMenuWidget(
              title: "Log Out",
              icon: FontAwesomeIcons.arrowLeft,
              onPress: () {
                context.read<LogInBloc>().add(LogOutRequired());
              },
              endIcon: false,
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

