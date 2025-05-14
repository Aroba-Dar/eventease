import 'package:event_ease/admin/form.dart';
import 'package:event_ease/admin/qr_verifier.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  final String userName;
  final String profileImageUrl;

  const AdminHomePage({
    super.key,
    this.userName = "Admin User",
    this.profileImageUrl =
        "https://cdn-icons-png.flaticon.com/512/149/149071.png", // Default profile
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            SizedBox(width: 10),
            Text(
              "Welcome, $userName",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 156, 39, 176),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(
                Icons.event,
                color: Colors.white,
              ),
              label: Text("Create New Event",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Color.fromARGB(255, 156, 39, 176),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OrganizerEventForm()), // Replace with your form
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.qr_code_scanner, color: Colors.white),
              label: Text("Check Valid Tickets",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRVerifierPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
