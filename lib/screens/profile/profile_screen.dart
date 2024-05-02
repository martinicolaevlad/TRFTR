import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sh_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:sh_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:sh_app/blocs/shop_blocs/get_shop_bloc.dart';
import 'package:sh_app/screens/home/detail_screen.dart';
import 'package:sh_app/screens/profile/create_shop_screen.dart';
import 'package:sh_app/screens/profile/shop_profile_screen.dart';
import 'package:sh_app/screens/profile/user_profile_screen.dart';
import 'package:shop_repository/shop_repository.dart';
import '../../blocs/log_in_bloc/log_in_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseShopRepo _shopRepo = FirebaseShopRepo(); // Instantiate FirebaseShopRepo

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, userState) {
        if (userState.user == null) {
          return Text('Error: No user found!');
        }

        if (!userState.user!.isOwner) {
          // User is not an owner, show user profile screen
          return UserProfileScreen();
        } else {
          // User is an owner, manage shop details
          return FutureBuilder<MyShop?>(
            future: _shopRepo.getShopByOwnerId(userState.user!.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.data == null) {
                // No shop found for the owner, prompt to create a new shop
                return CreateShopScreen(userState.user!);
              } else {
                // Shop found, show details screen
                return ShopProfileScreen(shop: snapshot.data!);
              }
            },
          );
        }
      },
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey,
        ),
        child: Icon(icon),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.apply(color: textColor),
      ),
      trailing: endIcon
          ? Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: Center(child: const FaIcon(FontAwesomeIcons.arrowRight)),
      )
          : null,
    );
  }
}
