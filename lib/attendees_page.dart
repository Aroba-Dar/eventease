import 'package:flutter/material.dart';

class AttendeesPage extends StatelessWidget {
  const AttendeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendees")),
      body: ListView.builder(
        itemCount: 20, // Example ke liye 20 attendees
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage("assets/images/profile_image.jpg"),
            ),
            title: Text("Attendee ${index + 1}"),
            trailing: ElevatedButton(
              onPressed: () {},
              child: Text("Follow"),
            ),
          );
        },
      ),
    );
  }
}
