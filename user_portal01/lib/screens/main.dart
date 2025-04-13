import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_portal01/screens/discussion_page.dart';
import 'theme_notifier.dart';
import 'package:user_portal01/screens/landing_page.dart';
import 'package:user_portal01/screens/sign_up_page.dart';
import 'package:user_portal01/screens/loginpage.dart';
import 'package:user_portal01/screens/dash_board.dart';

import 'package:user_portal01/screens/water_channel.dart';
import 'package:user_portal01/screens/electricity_channel.dart';
import 'package:user_portal01/screens/health_services_channel.dart';
import 'package:user_portal01/police_channel.dart';
import 'package:user_portal01/screens/notification.dart';
import 'package:user_portal01/screens/profile.dart';

import 'package:user_portal01/screens/channel.dart';
import 'package:user_portal01/screens/communities.dart';

void main() {
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const LandingPage(),
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const MyLoginPage(),
        '/dashboard': (context) => const Dashboard(),
        '/discussion': (context) => const Discussion(),
        '/waterUtilities': (context) => const WaterChannel(),
        '/electricity': (context) => const ElectricityChannel(),
        '/policeServices': (context) => const PoliceChannel(),
        '/healthServices': (context) => const HealthChannel(),
        '/notifications': (context) => const NotificationPage(),
        '/channels': (context) => const ChannelsPage(),
        '/profile': (context) => const ProfilePage(),
        '/communities': (context) => const CommunitiesPage(),
        '/notification': (context) => const NotificationPage(),
      },
    );
  }
}
