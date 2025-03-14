import 'package:flutter/material.dart';
import 'package:user_portal01/dash_board.dart';
import 'package:user_portal01/landing_page.dart';
import 'package:user_portal01/loginpage.dart';
import 'package:user_portal01/sign_up_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const MyLoginPage(),
        '/dashboard': (context) => const Dashboard(),
      },
    );
  }
}
