import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  final Color primaryColor = const Color.fromARGB(255, 156, 39, 176);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 70),
            Text(
              "EventEase",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // in double quotes statement
              "\"Your smart event booking solution\"",
              style: TextStyle(fontSize: 17, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: PageView(
                controller: _controller,
                children: [
                  buildPage(
                    title: "Are you an Organizer?",
                    description: "Create and manage events seamlessly.",
                    image: Icons.event_available,
                    buttonText: "Start as Organizer",
                    onPressed: () => Navigator.pushNamed(context, '/'),
                  ),
                  buildPage(
                    title: "Are you a User?",
                    description: "Discover and book your favorite events.",
                    image: Icons.person,
                    buttonText: "Start as User",
                    onPressed: () => Navigator.pushNamed(context, '/userlogin'),
                  ),
                ],
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: 2,
              effect: ExpandingDotsEffect(
                activeDotColor: primaryColor,
                dotColor: primaryColor.withOpacity(0.3),
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildPage({
    required String title,
    required String description,
    required IconData image,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final Color primaryColor = const Color.fromARGB(255, 156, 39, 176);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(image, size: 60, color: primaryColor),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: Text(
                buttonText,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
