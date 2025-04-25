import 'package:flutter/material.dart';
import 'auth/login.dart'; // Your new login/register page
import 'home_page.dart'; // Your existing home page
import 'package:flutter_stripe/flutter_stripe.dart';

void main() {
  Stripe.publishableKey =
      'pk_test_51RHjJWIpuAYC0tEaNBS68cmQJJXfItuAONhWEpPSmqHrvRAwZvjynvFiVv4TvB3E7Ar5N4uoU1D7Wz5Y8tAyWM3v00ux1mE43p';
  runApp(const EventEaseApp());
}

class EventEaseApp extends StatelessWidget {
  const EventEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Ease',
      theme: ThemeData(
        primaryColor: const Color(0xFF6D62F4),
        fontFamily: 'Arial',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginRegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
