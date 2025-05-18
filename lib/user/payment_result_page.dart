import 'package:flutter/material.dart';
import 'package:event_ease/user/e_ticket_page.dart';

// Payment Result Popup to display success message after payment
class PaymentResultPopup extends StatelessWidget {
  final String eventName; // Name of the event
  final String eventDate; // Date of the event
  final String eventLocation; // Location of the event
  final String userName; // Name of the user
  final String userEmail; // Contact information of the user
  final String userContact; // Contact information of the user
  final String bookingId; // Booking ID for the event
  final int organizerId; // Organizer ID for the event
  final int eventId; // Event ID for the event

  const PaymentResultPopup({
    super.key,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.userName,
    required this.userEmail,
    required this.userContact,
    required this.bookingId,
    required this.organizerId,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the content
          child: Column(
            mainAxisSize: MainAxisSize.min, // Minimize the column size
            children: [
              // Success icon in a circular container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 156, 39, 176)
                      .withOpacity(0.1), // Light purple background
                  shape: BoxShape.circle, // Circular shape
                ),
                child: const Center(
                  child: Icon(
                    Icons.check, // Checkmark icon
                    size: 50,
                    color: Color.fromARGB(255, 156, 39, 176), // Purple color
                  ),
                ),
              ),
              const SizedBox(height: 16), // Space between icon and text
              const Text(
                'Congratulations!', // Success message
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 156, 39, 176), // Purple color
                ),
              ),
              const SizedBox(height: 8), // Space between title and description
              Text(
                'You have successfully placed an order for $eventName.\nEnjoy the event!', // Event success message
                textAlign: TextAlign.center, // Center-align the text
              ),
              const SizedBox(height: 16), // Space before buttons
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center-align buttons
                children: [
                  // Button to view the e-ticket
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                          255, 156, 39, 176), // Purple button color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                    onPressed: () {
                      // Navigate to the E-Ticket page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ETicketPage(
                            eventName: eventName,
                            eventDate: eventDate,
                            eventLocation: eventLocation,
                            userName: userName,
                            userEmail: userEmail,
                            userContact: userContact,
                            bookingId: bookingId,
                            organizerId: organizerId,
                            eventId: eventId,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View E-Ticket', // Button text
                      style: TextStyle(color: Colors.white), // White text color
                    ),
                  ),
                  const SizedBox(width: 12), // Space between buttons
                  // Button to cancel and close the popup
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                    onPressed: () => Navigator.pop(context), // Close the popup
                    child: const Text(
                      'Cancel', // Button text
                      style: TextStyle(
                        color: Color.fromARGB(
                            255, 156, 39, 176), // Purple text color
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
