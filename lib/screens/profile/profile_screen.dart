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
import 'package:shop_repository/shop_repository.dart';
import '../../blocs/log_in_bloc/log_in_bloc.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseShopRepo _shopRepo = FirebaseShopRepo();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, userState) {
        return BlocBuilder<GetShopBloc, GetShopState>(
            builder: (context, shopState) {
              return Scaffold(
                body: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: const FaIcon(FontAwesomeIcons.userNinja, size: 100),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          BlocBuilder<MyUserBloc, MyUserState>(
                            builder: (context, state) {
                              if (state.user != null && state.user?.name != null) {
                                return Text(
                                  state.user!.name,
                                  style: Theme.of(context).textTheme.displayMedium,
                                );
                              } else {
                                return Text("error");
                              }
                            },
                          ),

                          BlocBuilder<AuthenticationBloc, AuthenticationState>(
                              builder: (context, state) {
                                if (state.user != null && state.user?.email != null) {
                                  return Text(
                                    state.user!.email!,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  );
                                } else {
                                  return Text("error");
                                }
                              }
                          ),

                          const SizedBox(height: 20),



                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 10),

                          ProfileMenuWidget(title: "Edit Profile", icon: FontAwesomeIcons.box, onPress: () {}),
                          if (context.read<MyUserBloc>().state.user!.isOwner)
                            ProfileMenuWidget(title: "My Shop", icon: FontAwesomeIcons.moneyBill, onPress: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => CreateShopScreen(context.read<MyUserBloc>().state.user!))); // Navigate to the CreateShopScreen
                            }),
                          ProfileMenuWidget(title: "Info", icon: FontAwesomeIcons.heart, onPress: () {}),
                          const Divider(),
                          const SizedBox(height: 10),
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
                  ),
                ),
              );
              }

        );
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
