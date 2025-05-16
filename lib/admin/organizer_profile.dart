import 'package:flutter/material.dart';

class OrganizerProfilePage extends StatelessWidget {
  final Map<String, dynamic> organizerData;

  const OrganizerProfilePage({super.key, required this.organizerData});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color.fromARGB(255, 156, 39, 176);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("My Profile",
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(organizerData['profileImage']),
              radius: 60,
            ),
            const SizedBox(height: 25),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBoldInfoRow(
                        "Name", organizerData['organizerName'], primaryColor),
                    _buildBoldInfoRow(
                        "Email", organizerData['email'], primaryColor),
                    _buildBoldInfoRow("Contact", organizerData['contactNumber'],
                        primaryColor),
                    _buildBoldInfoRow(
                        "Gender", organizerData['gender'], primaryColor),
                    _buildBoldInfoRow(
                        "Date of Birth", organizerData['dob'], primaryColor),
                    _buildBoldInfoRow(
                        "Country", organizerData['country'], primaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
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
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoldInfoRow(String label, String value, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label:  ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: accentColor,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
