import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/log_in_bloc/log_in_bloc.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center, // Moved alignment here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Log out"),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.arrowLeft), // Changed circleArrowLeft to arrowLeft
              onPressed: () {
                context.read<LogInBloc>().add(LogOutRequired());
              },
            ),
          ],
        ),
      ),
    );
  }
}
