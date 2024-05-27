import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sh_app/simple_bloc_observer.dart';
import 'package:user_repository/user_repository.dart';

import 'app.dart';
import 'components/messaging.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // This should be the first line in main.

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate();

  final MessagingService _messagingService = MessagingService();
  await _messagingService.initMessaging(); // Make sure this is async and awaited if it's setting up async operations.

  // Optional: Setup for Bloc if you use Bloc patterns in your app
  // Bloc.observer = SimpleBlocObserver();

  // Lock orientation to portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MainApp(FirebaseUserRepository()));
}
