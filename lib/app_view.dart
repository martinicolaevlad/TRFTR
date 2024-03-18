import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sh_app/screens/start/start_screen.dart';
import 'blocs/log_in_bloc/log_in_bloc.dart';
import 'components/persistent_nav.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.red.shade900,
      ),
      debugShowCheckedModeBanner: false,
      title: '2ND',
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) { // Remove 'const' keyword
          if (state.status == AuthenticationStatus.authenticated) {
            return BlocProvider(
                create: (context) => LogInBloc(
                  userRepository: context.read<AuthenticationBloc>().userRepository
                ),
                child: const PersistentTabScreen(),
            );
          } else {
            return const StartScreen();
          }
        },
      ),
    );
  }
}
