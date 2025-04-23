import 'package:flutter/material.dart';
import 'auth/login.dart'; // Your new login/register page
import 'home_page.dart'; // Your existing home page

void main() {
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
