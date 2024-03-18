import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sh_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'app_view.dart';
import 'firebase_options.dart';

class MainApp extends StatelessWidget {
  final UserRepository userRepository;
  const MainApp(this.userRepository, {super.key});
  // const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiRepositoryProvider(
        providers: [
        RepositoryProvider<AuthenticationBloc>(
            create: (_) => AuthenticationBloc(
              myUserRepository: userRepository
            )
        )
      ],
      child: const MyAppView());
    // return MyAppView();

  }
}

