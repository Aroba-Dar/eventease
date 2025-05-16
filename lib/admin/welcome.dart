import 'package:flutter/material.dart';

class OrganizerLandingPage extends StatelessWidget {
  const OrganizerLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color.fromARGB(255, 156, 39, 176);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/app_logo.jpeg',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
              // Welcome Text with RichText
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Welcome to ",
                      style: TextStyle(color: Colors.black, fontSize: 22),
                    ),
                    TextSpan(
                      text: "EventEase",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Rest unchanged
              Text(
                "A Smart Event Ticketing App",
                style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    color: Color.fromARGB(255, 156, 39, 176),
                    size: 23,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Feel free to add your events",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: primaryColor,
                ),
                onPressed: () {
                  // Navigate to Login page
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Login",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: primaryColor),
                ),
                onPressed: () {
                  // Navigate to Signup page
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 18, color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
