import 'package:flutter/material.dart';
import 'package:event_ease/e_ticket_page.dart';

class PaymentResultPopup extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String userName;
  final String userContact;
  final String bookingId;

  const PaymentResultPopup({
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 156, 39, 176).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 50,
                    color: Color.fromARGB(255, 156, 39, 176),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 156, 39, 176),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have successfully placed an order for $eventName.\nEnjoy the event!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 156, 39, 176),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ETicketPage(
                            eventName: eventName,
                            eventDate: eventDate,
                            eventLocation: eventLocation,
                            userName: userName,
                            userContact: userContact,
                            bookingId: bookingId,
                          ),
                        ),
                      );
                    },
                    child: const Text('View E-Ticket',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Color.fromARGB(255, 156, 39, 176))),
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
