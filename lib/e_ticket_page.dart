import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ETicketPage extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String userName;
  final String userContact;
  final String bookingId;

  const ETicketPage({
    super.key,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.userName,
    required this.userContact,
    required this.bookingId,
  });

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
            QrImageView(
              data: bookingId,
              version: QrVersions.auto,
              size: 200,
            ),
            SizedBox(height: 20),

            // Event Details
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow("Event", eventName),
                    _buildDetailRow("Date", eventDate),
                    _buildDetailRow("Venue", eventLocation),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),

            // User Details
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow("Name", userName),
                    _buildDetailRow("Contact", userContact),
                    _buildDetailRow("Booking ID", bookingId),
                  ],
                ),
              ),
            ),
            Spacer(),

            ElevatedButton(
              onPressed: () => _downloadTicket(context),
              child: Text("Download Ticket",
                  style: TextStyle(color: Color.fromARGB(255, 156, 39, 176))),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _downloadTicket(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ticket downloaded successfully")),
    );
  }
}
