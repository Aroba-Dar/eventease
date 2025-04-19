// import 'package:event_ease/auth/register.dart';
// import 'package:event_ease/auth/register_get.dart';
//import 'package:event_ease/test.dart';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the HomePage file

void main() {
  runApp(EventEaseApp());
}

class EventEaseApp extends StatelessWidget {
  const EventEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Ease',
      theme: ThemeData(
        primaryColor: Color(0xFF6D62F4),
        fontFamily: 'Arial', // Replace with your preferred font
      ),
      home: HomePage(), // Set HomePage as the initial screen
    );
  }
}
