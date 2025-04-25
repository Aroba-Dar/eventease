import 'package:event_ease/pin_page.dart';
import 'package:flutter/material.dart';

class ReviewSummaryPage extends StatelessWidget {
  final Map<String, dynamic> event;
  final int seatCount;
  final double totalPrice;
  final String paymentMethod;

  const ReviewSummaryPage({
    super.key,
    required this.event,
    required this.seatCount,
    required this.totalPrice,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final taxAmount = totalPrice * 0.1; // 10% tax
    final grandTotal = totalPrice + taxAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Summary"),
        centerTitle: true,
      ),
      body: Column(
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(event['imageUrl'] ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'] ?? 'Event',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(event['dateTime'] ?? ''),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 4),
                                    Text(event['location'] ?? ''),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserDetailRow("Full Name", "Andrew Ainsley"),
                          _buildUserDetailRow("Phone", "+1 111 467 378 399"),
                          _buildUserDetailRow("Email", "andrew_ainsley@yo.com"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seat and Payment Summary
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                              "$seatCount Seat${seatCount > 1 ? 's' : ''} (${event['category'] ?? 'General'})",
                              "\$${totalPrice.toStringAsFixed(2)}"),
                          _buildSummaryRow(
                              "Tax (10%)", "\$${taxAmount.toStringAsFixed(2)}"),
                          const Divider(),
                          _buildSummaryRow(
                              "Total", "\$${grandTotal.toStringAsFixed(2)}",
                              isTotal: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Method
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: _getPaymentMethodIcon(paymentMethod),
                      title: Text(_formatPaymentMethod(paymentMethod)),
                      trailing: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Change",
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnterPinPage(
                        // event: event,
                        // seatCount: seatCount,
                        // totalAmount: grandTotal,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Icon _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'credit card':
        return const Icon(Icons.credit_card, size: 40);
      case 'easypaisa':
        return const Icon(Icons.account_balance_wallet, size: 40);
      case 'jazzcash':
        return const Icon(Icons.money, size: 40);
      default:
        return const Icon(Icons.payment, size: 40);
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'credit card':
        return 'Credit Card •••• 4679'; // Masked for security
      default:
        return method;
    }
  }
}
