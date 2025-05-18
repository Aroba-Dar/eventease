import 'dart:convert';
// import 'dart:typed_data';
import 'package:event_ease/admin/form.dart';
import 'package:event_ease/admin/organizer_event_page.dart';
import 'package:event_ease/admin/qr_verifier.dart';
import 'package:event_ease/admin/organizer_profile.dart';
import 'package:event_ease/admin/ticket_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminHomePage extends StatefulWidget {
  final int organizerId;

  const AdminHomePage({super.key, required this.organizerId});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  String userName = "Loading...";
  String profileImageUrl =
      "https://cdn-icons-png.flaticon.com/512/149/149071.png";

  Map<String, dynamic> organizerData = {};

  @override
  void initState() {
    super.initState();
    fetchOrganizerDetails();
  }

  // Fetch organizer details from backend API and update state.
  Future<void> fetchOrganizerDetails() async {
    final url =
        Uri.parse('http://192.168.1.6:8081/organizers/${widget.organizerId}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          organizerData = data;
          userName = data['organizerName'] ?? 'No Name';
          profileImageUrl = data['profileImage'] ?? profileImageUrl;
        });
      } else {
        setState(() {
          userName = "Organizer not found";
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error loading data";
      });
    }
  }

  // Builds the profile image widget, navigates to profile page on tap.
  Widget buildProfileImage(String imageStr) {
    return GestureDetector(
      onTap: () {
        if (organizerData.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrganizerProfilePage(
                organizerData: organizerData,
              ),
            ),
          );
        }
      },
      child: CircleAvatar(
        backgroundImage: imageStr.startsWith('http')
            ? NetworkImage(imageStr)
            : MemoryImage(base64Decode(imageStr)) as ImageProvider,
        radius: 20,
      ),
    );
  }

  // Handles bottom navigation bar item tap.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Home content with buttons for creating events and verifying tickets.
  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.event, color: Colors.white),
            label:
                Text("Create New Event", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Color.fromARGB(255, 156, 39, 176),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrganizerEventForm(
                    organizerId: widget.organizerId,
                  ),
                ),
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
    );
  }

  // List of pages for navigation.
  List<Widget> get _pages => [
        _buildHomeContent(),
        OrganizerEventsPage(organizerId: widget.organizerId),
        MyTicketsPage(organizerId: widget.organizerId),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            buildProfileImage(profileImageUrl),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Welcome, $userName ",
                style: TextStyle(color: Colors.white),
                // overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 156, 39, 176),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 156, 39, 176),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'My Tickets',
          ),
        ],
      ),
    );
  }
}
