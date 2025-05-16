import 'dart:convert';
import 'package:event_ease/payment_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  double ticketPrice = 0.0;
  double vipPrice = 0.0;
  int economySeats = 0;
  int vipSeats = 0;
  double discount = 0.0;
  bool isEconomy = true;

  @override
  void initState() {
    super.initState();
    fetchSeatPricing(widget.eventId);
  }

  Future<void> fetchSeatPricing(int eventId) async {
    final url =
        Uri.parse('http://192.168.1.6:8081/api/seat-pricing/by-event/$eventId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final pricing = data[0];

          setState(() {
            ticketPrice = (pricing['economyPrice'] ?? 500).toDouble();
            vipPrice = (pricing['vipPrice'] ?? 1000).toDouble();
            economySeats = pricing['economySeats'] ?? 0;
            vipSeats = pricing['vipSeats'] ?? 0;
            discount = (pricing['discount'] ?? 0).toDouble();
          });

          print(
              "Fetched pricing: Economy: $ticketPrice, VIP: $vipPrice, Disc: $discount%");
        }
      } else {
        print("Error fetching seat pricing: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventName = widget.event['name'] ?? "Event Seat Booking";
    debugPrint('Organizer ID: ${widget.event['organizerId']}');

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

          // Display pricing and discount
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text("Economy Price: \$${ticketPrice.toStringAsFixed(2)}"),
          //       Text("VIP Price: \$${vipPrice.toStringAsFixed(2)}"),
          //       Text("Economy Seats Available: $economySeats"),
          //       Text("VIP Seats Available: $vipSeats"),
          //       if (discount > 0) Text("🎉 Discount: $discount%"),
          //     ],
          //   ),
          // ),

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
                final basePrice = isEconomy ? ticketPrice : vipPrice;
                final discountedPrice =
                    basePrice - (basePrice * (discount / 100));
                final totalPrice = seatCount * discountedPrice;

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
                backgroundColor: const Color.fromARGB(255, 156, 39, 176),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                "Continue - \$${(seatCount * (isEconomy ? ticketPrice : vipPrice) * (1 - discount / 100)).toStringAsFixed(2)}",
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
                        ? const Color.fromARGB(255, 156, 39, 176)
                        : Colors.grey)),
            const SizedBox(height: 4),
            if (selected)
              Container(
                  height: 2,
                  width: 60,
                  color: const Color.fromARGB(255, 156, 39, 176)),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, bool isIncrement) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          int availableSeats = isEconomy ? economySeats : vipSeats;

          if (isIncrement) {
            if (seatCount < availableSeats) {
              seatCount++;
            }
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
