import 'dart:developer';

import 'package:favorite_repository/favorite_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sh_app/blocs/favorite_bloc/favorite_bloc.dart';
import 'package:sh_app/blocs/shop_blocs/create_shop_bloc.dart';
import 'package:sh_app/blocs/shop_blocs/get_shop_bloc.dart';
import 'package:sh_app/screens/home/detail_screen.dart';
import 'package:sh_app/screens/home/home_screen.dart';
import 'package:sh_app/screens/start/start_screen.dart';
import 'package:sh_app/themes/theme.dart';
import 'package:shop_repository/shop_repository.dart';
import 'blocs/log_in_bloc/log_in_bloc.dart';
import 'blocs/register_bloc/register_bloc.dart';
import 'blocs/shop_blocs/update_shop_bloc.dart';
import 'components/persistent_nav.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';

import 'package:provider/provider.dart'; // Import the provider package
import 'blocs/authentication_bloc/authentication_bloc.dart'; // Import your blocs
import 'blocs/my_user_bloc/my_user_bloc.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: TAppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        title: 'TRFTR',
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      if (state.status == AuthenticationStatus.authenticated) {
        return MultiBlocProvider(
            providers: [
                BlocProvider(
                  create: (context) => LogInBloc(
                      userRepository: context.read<AuthenticationBloc>().userRepository
                  ),
                ),
                BlocProvider(
                  create: (context) => MyUserBloc(
                      myUserRepository: context.read<AuthenticationBloc>().userRepository
                  )..add(GetMyUser(
                      myUserId: context.read<AuthenticationBloc>().state.user!.uid
                  )),
                ),
                BlocProvider(
                  create: (context) => GetShopBloc(
                      FirebaseShopRepo()
                  )..add(GetShop()),
                ),
                BlocProvider(
                  create: (context) => CreateShopBloc(shopRepo: FirebaseShopRepo())
                ),
              BlocProvider(
                  create: (context) => UpdateShopBloc(shopRepo: FirebaseShopRepo())
                ),
              BlocProvider(create: (context) => FavoritesBloc(favoritesRepo: FirebaseFavoriteRepo()),
                )
            ] ,
           child: const PersistentTabScreen());
      }else{
        return StartScreen();
      }
      }
    ));}}