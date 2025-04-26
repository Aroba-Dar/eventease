import 'package:event_ease/payment_selection_page.dart';
import 'package:flutter/material.dart';

class BookEventSeatPage extends StatefulWidget {
  final Map<String, dynamic> event;
  final int eventId;

  const BookEventSeatPage(
      {super.key, required this.event, required this.eventId});

  @override
  _BookEventSeatPageState createState() => _BookEventSeatPageState();
}

class _BookEventSeatPageState extends State<BookEventSeatPage> {
  int seatCount = 1;
  double ticketPrice = 0.0; // Changed to double
  double vipPrice = 0.0; // Added
  bool isEconomy = true;

  @override
  void initState() {
    super.initState();
    ticketPrice = (widget.event['economyPrice'] ?? 500.0).toDouble();
    vipPrice = (widget.event['vipPrice'] ?? 1000.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final eventName = widget.event['name'] ?? "Event Seat Booking";
    final vipPrice = widget.event['vipPrice'] ?? 1000;

    return Scaffold(
      appBar: AppBar(
        title: Text("Book Seat - $eventName",
            style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTab("Economy", isEconomy),
                _buildTab("VIP", !isEconomy),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                    _buildCounterButton(Icons.remove, false),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text("$seatCount",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    _buildCounterButton(Icons.add, true),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                final totalPrice =
                    (isEconomy ? seatCount * ticketPrice : seatCount * vipPrice)
                        .toDouble(); // <-- Force double

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentSelectionPage(
                      eventId: widget.eventId,
                      seatCount: seatCount,
                      totalPrice: totalPrice, // Now definitely double
                      event: widget.event,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 156, 39, 176),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                "Continue - \$${(isEconomy ? seatCount * ticketPrice : seatCount * vipPrice).toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isEconomy = text == "Economy";
          });
        },
        child: Column(
          children: [
            Text(text,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? Color.fromARGB(255, 156, 39, 176)
                        : Colors.grey)),
            const SizedBox(height: 4),
            if (selected)
              Container(
                  height: 2,
                  width: 60,
                  color: Color.fromARGB(255, 156, 39, 176)),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, bool isIncrement) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (isIncrement) {
            seatCount++;
          } else if (seatCount > 1) {
            seatCount--;
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: Colors.black),
    );
  }
}
