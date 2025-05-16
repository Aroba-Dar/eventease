import 'dart:convert';

import 'package:event_ease/pin_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Review Summary Page to display booking details and user information
class ReviewSummaryPage extends StatefulWidget {
  final Map<String, dynamic> event; // Event details
  final int seatCount; // Number of seats booked
  final double totalPrice; // Total price of the booking
  final String paymentMethod; // Selected payment method

  const ReviewSummaryPage({
    super.key,
    required this.event,
    required this.seatCount,
    required this.totalPrice,
    required this.paymentMethod,
  });

  @override
  State<ReviewSummaryPage> createState() => _ReviewSummaryPageState();
}

class _ReviewSummaryPageState extends State<ReviewSummaryPage> {
  late String userName = 'Loading...'; // User's name
  late String userEmail = 'Loading...'; // User's email
  late String userPhone = 'Loading...'; // User's phone number
  bool _isLoading = true; // Indicates if user data is being loaded

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page initializes
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Guest User';
      userEmail = prefs.getString('userEmail') ?? 'No email provided';
      userPhone = prefs.getString('userPhone') ?? 'No phone provided';
      _isLoading = false; // Data loading complete
    });
  }

  Widget _buildEventImage(String imageData) {
    if (imageData.startsWith('http')) {
      // It's a network image
      return Image.network(
        imageData,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    } else {
      // It's a Base64 image
      try {
        final bytes = base64Decode(imageData);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      } catch (e) {
        return const Icon(Icons.broken_image);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxAmount = widget.totalPrice * 0.01; // Calculate 10% tax
    final grandTotal = widget.totalPrice + taxAmount; // Calculate grand total
    debugPrint('Organizer ID: ${widget.event['organizerId']}');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Summary"), // AppBar title
        centerTitle: true, // Center the title
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loader while data is loading
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Details Card
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16), // Rounded corners
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Event image
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10), // Rounded corners
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _buildEventImage(
                                        widget.event['imageUrl'] ?? ''),
                                  ),
                                ),

                                const SizedBox(
                                    width:
                                        16), // Space between image and details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Event name
                                      Text(
                                        widget.event['name'] ?? 'Event',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      // Event date and time
                                      Text(widget.event['dateTime'] ?? ''),
                                      // Event location
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Text(widget.event['location'] ?? ''),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // User Details Card
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16), // Rounded corners
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display user details
                                _buildUserDetailRow("Full Name", userName),
                                _buildUserDetailRow("Email", userEmail),
                                _buildUserDetailRow("Phone", userPhone),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Seat and Payment Summary
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16), // Rounded corners
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Seat details and price
                                _buildSummaryRow(
                                    "${widget.seatCount} Seat${widget.seatCount > 1 ? 's' : ''} (${widget.event['category'] ?? 'General'})",
                                    "\$${widget.totalPrice.toStringAsFixed(2)}"),
                                // Tax details
                                _buildSummaryRow("Tax (1%)",
                                    "\$${taxAmount.toStringAsFixed(2)}"),
                                const Divider(), // Divider line
                                // Grand total
                                _buildSummaryRow("Total",
                                    "\$${grandTotal.toStringAsFixed(2)}",
                                    isTotal: true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Payment Method Card
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16), // Rounded corners
                          ),
                          child: ListTile(
                            leading: _getPaymentMethodIcon(
                                widget.paymentMethod), // Payment method icon
                            title: Text(_formatPaymentMethod(
                                widget.paymentMethod)), // Payment method name
                            trailing: TextButton(
                              onPressed: () => Navigator.pop(
                                  context), // Navigate back to change payment method
                              child: const Text("Change",
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 156, 39, 176))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the EnterPinPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnterPinPage(
                            event: widget.event,
                            seatCount: widget.seatCount,
                            totalAmount: grandTotal,
                            userName: userName,
                            userEmail: userEmail,
                            userPhone: userPhone,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 50), // Full-width button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    child: const Text("Continue",
                        style: TextStyle(
                            color: Color.fromARGB(255, 156, 39, 176))),
                  ),
                ),
              ],
            ),
    );
  }

  // Helper method to build user detail row
  Widget _buildUserDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Space between rows
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)), // Label
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)), // Value
        ],
      ),
    );
  }

  // Helper method to build summary row
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Space between rows
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label), // Label
          Text(
            value, // Value
            style: TextStyle(
              fontWeight: isTotal
                  ? FontWeight.bold
                  : FontWeight.normal, // Bold for total
              color: isTotal ? Colors.green : null, // Green color for total
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get payment method icon
  Icon _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'credit card':
        return const Icon(Icons.credit_card, size: 40); // Credit card icon
      case 'easypaisa':
        return const Icon(Icons.account_balance_wallet,
            size: 40); // Easypaisa icon
      case 'jazzcash':
        return const Icon(Icons.money, size: 40); // JazzCash icon
      default:
        return const Icon(Icons.payment, size: 40); // Default payment icon
    }
  }

  // Helper method to format payment method name
  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'credit card':
        return 'Credit Card •••• 4242'; // Masked credit card number
      default:
        return method; // Default method name
    }
  }
}
