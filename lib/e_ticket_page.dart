import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ETicketPage extends StatelessWidget {
  const ETicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("E-Ticket"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // QR Code
            QrImageView(
              data: "https://example.com/ticket/123456",
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 20),

            // Event Details Card

            // Event Details Card
            SizedBox(
              width: double
                  .infinity, // Ensures both cards take full available width
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBoldText("Event", "National Music Festival"),
                      _buildBoldText(
                          "Date and Hour", "Monday, Dec 24 - 18:00 - 23:00 PM"),
                      _buildBoldText(
                          "Event Location", "Grand Park, New York City, US"),
                      _buildBoldText("Event Organizer", "XYZ Events"),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

// User Details Card
            SizedBox(
              width: double
                  .infinity, // Ensures both cards take full available width
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNormalText("Full Name", "John Doe"),
                      _buildNormalText("Gender", "Male"),
                      _buildNormalText("Contact No.", "+1 123 456 7890"),
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),

            // Download Ticket Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // TODO: Implement ticket download functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Downloading Ticket...")),
                );
              },
              child: Text("Download Ticket"),
            ),
          ],
        ),
      ),
    );
  }

  // Bold text formatting for event details
  Widget _buildBoldText(String heading, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Text(
            detail,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Normal text formatting for user details
  Widget _buildNormalText(String heading, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            heading,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            detail,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
