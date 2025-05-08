import 'package:event_ease/payment_selection_page.dart';
import 'package:flutter/material.dart';

// Page for booking event seats
class BookEventSeatPage extends StatefulWidget {
  final Map<String, dynamic> event; // Event details
  final int eventId; // Event ID

  const BookEventSeatPage(
      {super.key, required this.event, required this.eventId});

  @override
  _BookEventSeatPageState createState() => _BookEventSeatPageState();
}

class _BookEventSeatPageState extends State<BookEventSeatPage> {
  int seatCount = 1; // Number of seats selected
  double ticketPrice = 0.0; // Economy ticket price
  double vipPrice = 0.0; // VIP ticket price
  bool isEconomy = true; // Indicates if the economy tab is selected

  @override
  void initState() {
    super.initState();
    // Initialize ticket prices from event details
    ticketPrice = (widget.event['economyPrice'] ?? 500.0).toDouble();
    vipPrice = (widget.event['vipPrice'] ?? 1000.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final eventName =
        widget.event['name'] ?? "Event Seat Booking"; // Event name
    final vipPrice = widget.event['vipPrice'] ?? 1000; // Default VIP price

    return Scaffold(
      appBar: AppBar(
        title: Text("Book Seat - $eventName",
            style: const TextStyle(color: Colors.black)), // AppBar title
        backgroundColor: Colors.white, // AppBar background color
        elevation: 0, // Remove AppBar shadow
        centerTitle: true, // Center the title
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Colors.black), // Back button
          onPressed: () => Navigator.pop(context), // Navigate back
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Tabs for selecting ticket type (Economy or VIP)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTab("Economy", isEconomy), // Economy tab
                _buildTab("VIP", !isEconomy), // VIP tab
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Seat selection section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Choose number of seats",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCounterButton(
                        Icons.remove, false), // Decrease seat count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text("$seatCount",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    _buildCounterButton(Icons.add, true), // Increase seat count
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Continue button to proceed to payment selection
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Calculate total price based on ticket type and seat count
                final totalPrice =
                    (isEconomy ? seatCount * ticketPrice : seatCount * vipPrice)
                        .toDouble();

                // Navigate to the payment selection page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentSelectionPage(
                      eventId: widget.eventId,
                      seatCount: seatCount,
                      totalPrice: totalPrice,
                      event: widget.event,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 156, 39, 176), // Button color
                minimumSize:
                    const Size(double.infinity, 50), // Full-width button
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)), // Rounded corners
              ),
              child: Text(
                // Display total price on the button
                "Continue - \$${(isEconomy ? seatCount * ticketPrice : seatCount * vipPrice).toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a tab for selecting ticket type
  Widget _buildTab(String text, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isEconomy = text == "Economy"; // Update selected tab
          });
        },
        child: Column(
          children: [
            Text(text,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? Color.fromARGB(
                            255, 156, 39, 176) // Selected tab color
                        : Colors.grey)), // Unselected tab color
            const SizedBox(height: 4),
            if (selected)
              Container(
                  height: 2,
                  width: 60,
                  color: Color.fromARGB(255, 156, 39, 176)), // Tab indicator
          ],
        ),
      ),
    );
  }

  // Builds a button for increasing or decreasing seat count
  Widget _buildCounterButton(IconData icon, bool isIncrement) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (isIncrement) {
            seatCount++; // Increment seat count
          } else if (seatCount > 1) {
            seatCount--; // Decrement seat count (minimum 1)
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Button background color
        shape: const CircleBorder(), // Circular button shape
        padding: const EdgeInsets.all(10), // Button padding
        side: BorderSide(color: Colors.grey.shade300), // Button border
      ),
      child: Icon(icon, color: Colors.black), // Button icon
    );
  }
}
