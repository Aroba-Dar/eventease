import 'package:event_ease/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Profile Page to display user details
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User profile details
  String firstName = '';
  String lastName = '';
  String email = '';
  String gender = '';
  String country = '';
  String phone = '';
  String dateOfBirth = '';
  String avatarUrl = ''; // Placeholder for user avatar

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load user profile data on page initialization
  }

  // Method to load user profile data from SharedPreferences
  _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return; // Prevent calling setState if widget is disposed

    setState(() {
      // Retrieve user details from SharedPreferences
      firstName = prefs.getString('firstName') ?? '';
      lastName = prefs.getString('lastName') ?? '';
      email = prefs.getString('userEmail') ?? '';
      gender = prefs.getString('gender') ?? 'Not set';
      country = prefs.getString('country') ?? 'Not set';
      phone = prefs.getString('userPhone') ?? 'Not set';
      dateOfBirth = prefs.getString('dateOfBirth') ?? 'Not set';

      // Set avatar image based on gender
      if (gender.toLowerCase() == 'male') {
        avatarUrl = 'assets/images/male.jpeg';
      } else if (gender.toLowerCase() == 'female') {
        avatarUrl = 'assets/images/female.jpeg';
      } else {
        avatarUrl = 'assets/images/male.jpeg'; // Default fallback avatar
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Colors.white), // Back button
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: const Text("Profile",
            style: TextStyle(color: Colors.white)), // AppBar title
        backgroundColor: const Color(0xFF9C27B0), // Primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar and Name Row
            Row(
              children: [
                CircleAvatar(
                  radius: 40, // Avatar size
                  backgroundImage: AssetImage(avatarUrl), // Avatar image
                ),
                const SizedBox(width: 16), // Space between avatar and name
                Text(
                  '$firstName $lastName', // Display user's full name
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 20), // Space between name and profile details

            // Profile Details Card
            Card(
              elevation: 4, // Card shadow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display user profile information
                    _buildProfileInfo("Email", email),
                    _buildProfileInfo("Phone", phone),
                    _buildProfileInfo("Date of Birth", dateOfBirth),
                    _buildProfileInfo("Gender", gender),
                    _buildProfileInfo("Country", country),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // Space before the button

            // Back to Home Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 24), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                onPressed: () {
                  // Navigate back to the home page
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text(
                  'Back to Home', // Button text
                  style: TextStyle(
                      color: Color(0xFF9C27B0), // Text color
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20), // Space before the button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, size: 22, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 246, 93, 93),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 6,
                  shadowColor: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginRegisterPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build profile info row
  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Space between rows
      child: Row(
        children: [
          Text(
            '$label: ', // Label for the profile field
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value, // Value of the profile field
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
