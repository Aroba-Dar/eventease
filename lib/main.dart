// import 'package:event_ease/admin/admin_home.dart';
import 'package:event_ease/admin/login_screen.dart';
import 'package:event_ease/admin/signup_screen.dart';
import 'package:event_ease/admin/welcome.dart';
import 'package:event_ease/auth/login.dart';
import 'package:event_ease/onboarding.dart';
import 'package:event_ease/user/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:event_ease/admin/form.dart';

void main() {
  // Setting up the Stripe publishable key for payment integration privat in the STS
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
      title: 'Event Ease', // App title

      // theme for the app
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 156, 39, 176),
        fontFamily: 'Arial',
      ),

      // // Setting the initial route of the app
      // // initialRoute: '/login',
      // // routes: {
      // //   '/login': (context) =>
      // //       const LoginRegisterPage(), // Login/Register screen
      // //   '/home': (context) => const HomePage(), // Home screen after login
      // // },
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => OrganizerLandingPage(),
      //   '/login': (context) => LoginScreen(),
      //   '/signup': (context) => SignupScreen(),
      // Setting the initial route of the app
      initialRoute: '/onboarding', // Start with onboarding

      routes: {
        '/onboarding': (context) => OnboardingPage(),

        '/': (context) => OrganizerLandingPage(), // Organizer home

        '/login': (context) => LoginScreen(), // Admin login
        '/signup': (context) => SignupScreen(), // Admin signup

        '/userlogin': (context) =>
            const LoginRegisterPage(), // User login/register
        '/home': (context) => const HomePage(),
      },
    );
  }
}
