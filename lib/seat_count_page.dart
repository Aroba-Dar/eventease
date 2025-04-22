import 'package:event_ease/payment_selection_page.dart';
import 'package:flutter/material.dart';

class BookEventSeatPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const BookEventSeatPage({super.key, required this.event});

  @override
  _BookEventSeatPageState createState() => _BookEventSeatPageState();
}

class _BookEventSeatPageState extends State<BookEventSeatPage> {
  int seatCount = 1;
  int ticketPrice = 50;
  bool isEconomy = true;

  @override
  Widget build(BuildContext context) {
    final eventName = widget.event['name'] ?? "Event Seat Booking";

    return Scaffold(
      appBar: AppBar(
        title: Text("Book Seat - $eventName",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTab("Economy", isEconomy),
                _buildTab("VIP", !isEconomy),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Choose number of seats",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCounterButton(Icons.remove, false),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("$seatCount",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    _buildCounterButton(Icons.add, true),
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentSelectionPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Continue - \$${seatCount * ticketPrice}",
                  style: TextStyle(fontSize: 18)),
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
            ticketPrice = isEconomy ? 50 : 100;
          });
        },
        child: Column(
          children: [
            Text(text,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.blueAccent : Colors.grey)),
            SizedBox(height: 4),
            if (selected)
              Container(height: 2, width: 60, color: Colors.blueAccent),
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
        shape: CircleBorder(),
        padding: EdgeInsets.all(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: Colors.black),
    );
  }
}
