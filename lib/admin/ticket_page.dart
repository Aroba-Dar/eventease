import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyTicketsPage extends StatefulWidget {
  final int organizerId;

  const MyTicketsPage({super.key, required this.organizerId});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  List<dynamic> tickets = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  // Fetches tickets for the organizer from the backend
  Future<void> fetchTickets() async {
    final url = Uri.parse(
        'http://localhost:8080/api/tickets/organizer/${widget.organizerId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          tickets = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Failed to load tickets (Status ${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching tickets: $e";
        isLoading = false;
      });
    }
  }

  // Helper widget to display a row with an icon and label/value
  Widget infoRow(IconData icon, String label) {
    // Split label at first colon for bold styling
    final splitIndex = label.indexOf(':');
    String labelPart = "";
    String valuePart = "";
    if (splitIndex != -1) {
      labelPart = label.substring(0, splitIndex + 1); // include colon
      valuePart = label.substring(splitIndex + 1);
    } else {
      labelPart = label;
      valuePart = "";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Color.fromARGB(255, 156, 39, 176)),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: labelPart,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: valuePart,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show loading indicator while fetching data
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      // Show error message if fetch failed
      return Center(child: Text(errorMessage));
    }

    if (tickets.isEmpty) {
      // Show message if no tickets found
      return Center(child: Text("No tickets found."));
    }

    // Build a list of ticket cards
    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Color.fromARGB(255, 156, 39, 176)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoRow(Icons.confirmation_num,
                    "Booking ID:  ${ticket['bookingId']}"),
                SizedBox(height: 8),
                infoRow(Icons.event, "Event:  ${ticket['eventName']}"),
                infoRow(Icons.calendar_today, "Date:  ${ticket['eventDate']}"),
                infoRow(
                    Icons.location_on, "Location:  ${ticket['eventLocation']}"),
                Divider(height: 20, color: Colors.grey),
                infoRow(Icons.person, "User Name:  ${ticket['userName']}"),
                infoRow(Icons.email, "Email:  ${ticket['userEmail']}"),
                infoRow(Icons.phone, "Contact:  ${ticket['userContact']}"),
              ],
            ),
          ),
        );
      },
    );
  }
}
