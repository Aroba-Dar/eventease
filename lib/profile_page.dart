import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String displayName = 'Guest';
  String gender = 'male';
  String email = '';
  String phone = '';
  bool isGuest = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final guest = prefs.getBool('isGuest') ?? true;
    setState(() {
      isGuest = guest;
    });

    if (!guest && savedEmail != null) {
      fetchUserData(savedEmail);
    } else {
      setGuestUser();
    }
  }

  void setGuestUser() {
    setState(() {
      displayName = 'Guest';
      gender = 'male';
      email = '';
      phone = '';
    });
  }

  Future<void> fetchUserData(String email) async {
    final url = Uri.parse('http://10.20.6.65:8081/users/email/$email');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        setState(() {
          displayName = '${user['firstName']} ${user['lastName']}';
          gender = user['gender'] ?? 'male';
          email = user['email'];
          phone = user['phone'];
        });
      } else {
        setGuestUser();
      }
    } catch (e) {
      setGuestUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: gender == 'female'
                      ? AssetImage('assets/images/organizer.jpg')
                      : AssetImage('assets/images/profile_image.jpg'),
                  radius: 40,
                ),
                const SizedBox(width: 16),
                Text(displayName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Email: $email'),
            Text('Phone: $phone'),
            // Add more user details if needed
          ],
        ),
      ),
    );
  }
}
