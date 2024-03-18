import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sh_app/blocs/log_in_bloc/log_in_bloc.dart';
import 'log_in_screen.dart';
import 'package:sh_app/screens/start/register_screen.dart';
import '../../blocs/register_bloc/register_bloc.dart';
import '../../blocs/authentication_bloc/authentication_bloc.dart';



class StartScreen extends StatefulWidget {
  const  StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Text(
                  'second',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,

                  ),
                ),
                const SizedBox(height: kToolbarHeight),
                TabBar(
                    controller: tabController,
                    unselectedLabelColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                    labelColor: Theme.of(context).colorScheme.onBackground,
                    tabs: const [
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ]
                ),
                Expanded(
                  child: TabBarView(
                      controller: tabController,
                      children: [
                        BlocProvider<LogInBloc>(
                          create: (context) => LogInBloc(
                              userRepository: context.read<AuthenticationBloc>().userRepository
                          ),
                          child: const LogInScreen(),
                        ),
                        BlocProvider<RegisterBloc>(
                          create: (context) => RegisterBloc(
                              userRepository: context.read<AuthenticationBloc>().userRepository
                          ),
                          child: const RegisterScreen(),
                        ),
                      ]
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}