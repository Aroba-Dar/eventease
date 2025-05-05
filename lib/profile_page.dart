import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    _loadUserProfile();
  }

  // Method to load user profile data from SharedPreferences
  // Method to load user profile data from SharedPreferences
  _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return; // Prevent calling setState if widget is disposed

    setState(() {
      firstName = prefs.getString('firstName') ?? '';
      lastName = prefs.getString('lastName') ?? '';
      email = prefs.getString('userEmail') ?? '';
      gender = prefs.getString('gender') ?? 'Not set';
      country = prefs.getString('country') ?? 'Not set';
      phone = prefs.getString('userPhone') ?? 'Not set';
      dateOfBirth = prefs.getString('dateOfBirth') ?? 'Not set';

      if (gender.toLowerCase() == 'male') {
        avatarUrl = 'assets/images/male.jpeg';
      } else if (gender.toLowerCase() == 'female') {
        avatarUrl = 'assets/images/female.jpeg';
      } else {
        avatarUrl = 'assets/images/male.jpeg'; // default fallback
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor:
            const Color(0xFF9C27B0), // Using the same primary color
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
                  radius: 40,
                  backgroundImage: AssetImage(avatarUrl),
                ),
                const SizedBox(width: 16),
                Text(
                  '$firstName $lastName',
                  style: TextStyle(
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
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInfo("Email", email),
                    _buildProfileInfo("Phone", phone),
                    _buildProfileInfo("Date of Birth", dateOfBirth),
                    _buildProfileInfo("Gender", gender),
                    _buildProfileInfo("Country", country),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Back to Home Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Color(0xFF9C27B0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                      color: Color(0xFF9C27B0),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
