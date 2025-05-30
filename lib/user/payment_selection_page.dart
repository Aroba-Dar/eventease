import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:event_ease/user/review_summary_page.dart';

class PaymentSelectionPage extends StatefulWidget {
  final int eventId;
  final int seatCount;
  final double totalPrice;
  final Map<String, dynamic> event;

  const PaymentSelectionPage({
    super.key,
    required this.eventId,
    required this.seatCount,
    required this.totalPrice,
    required this.event,
  });

  @override
  _PaymentSelectionPageState createState() => _PaymentSelectionPageState();
}

class _PaymentSelectionPageState extends State<PaymentSelectionPage> {
  int _selectedPaymentMethod =
      1; // Selected payment method (default: EasyPaisa)
  bool _isProcessing = false; // Indicates if a payment is being processed
  final CardFormEditController _controller =
      CardFormEditController(); // Controller for Stripe card form

  @override
  void initState() {
    super.initState();
    // Set the Stripe publishable key
    Stripe.publishableKey =
        'pk_test_51RHjJWIpuAYC0tEaNBS68cmQJJXfItuAONhWEpPSmqHrvRAwZvjynvFiVv4TvB3E7Ar5N4uoU1D7Wz5Y8tAyWM3v00ux1mE43p';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Organizer ID: ${widget.event['organizerId']}');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Payments"),
        centerTitle: true,
        backgroundColor: Colors.purple[100],
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instruction text
                  Text(
                    "Select the payment method you want to use.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  // Payment options
                  _buildPaymentOption(
                      1, "EasyPaisa", Icons.account_balance_wallet),
                  const SizedBox(height: 10),
                  _buildPaymentOption(2, "JazzCash", Icons.money),
                  const SizedBox(height: 10),
                  _buildPaymentOption(3, "Credit Card", Icons.credit_card),
                  const SizedBox(height: 20),
                  // Stripe card form for credit card payment
                  if (_selectedPaymentMethod == 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: CardFormField(
                        controller: _controller,
                        style: CardFormStyle(
                          borderColor: Colors.purple.shade100,
                          borderRadius: 12,
                          textColor: Colors.black87,
                          backgroundColor: Colors.grey[50],
                          borderWidth: 2, //
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  // Continue button to proceed with payment
                  ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : _handlePayment, // Handle payment on press
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(
                            color: Colors.white) // Show loader if processing
                        : const Text("Continue"), // Button text
                  ),
                ],
              ),
            ),
            // Show a loading overlay if payment is being processed
            if (_isProcessing)
              const ModalBarrier(
                dismissible: false,
                color: Colors.black54, // Semi-transparent background
              ),
            if (_isProcessing)
              const Center(
                child: CircularProgressIndicator(), // Loading spinner
              ),
          ],
        ),
      ),
    );
  }

  // Widget to build a payment option
  Widget _buildPaymentOption(int value, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.black), // Payment method icon
      title: Text(title,
          style: const TextStyle(fontSize: 18)), // Payment method title
      trailing: Radio(
        value: value, // Value of the payment method
        groupValue: _selectedPaymentMethod, // Currently selected method
        onChanged: (int? newValue) {
          setState(() {
            _selectedPaymentMethod = newValue ?? 1; // Update selected method
          });
        },
        activeColor: Colors.purple, // Active radio button color
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
        side: BorderSide(color: Colors.grey.shade300), // Border color
      ),
      tileColor: Colors.grey.shade100, // Background color
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Padding
    );
  }

  // Handle payment based on the selected method
  void _handlePayment() {
    if (_selectedPaymentMethod == 1) {
      _showMockPaymentDialog("EasyPaisa"); // Simulate EasyPaisa payment
    } else if (_selectedPaymentMethod == 2) {
      _showMockPaymentDialog("JazzCash"); // Simulate JazzCash payment
    } else if (_selectedPaymentMethod == 3) {
      _makeStripePayment(); // Process Stripe payment
    }
  }

  // Show a mock payment dialog for EasyPaisa or JazzCash
  void _showMockPaymentDialog(String methodName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$methodName Payment"), // Dialog title
        content: Text(
            "Simulated payment successful via $methodName!"), // Dialog content
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        "$methodName Payment Confirmed!")), // Show confirmation
              );
              // Navigate to the review summary page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewSummaryPage(
                    event: widget.event,
                    seatCount: widget.seatCount,
                    totalPrice: widget.totalPrice,
                    paymentMethod: methodName,
                  ),
                ),
              );
            },
            child: const Text("OK",
                style: TextStyle(
                    color: Color.fromARGB(255, 156, 39, 176))), // Button text
          )
        ],
      ),
    );
  }

  // Process payment using Stripe
  Future<void> _makeStripePayment() async {
    setState(() => _isProcessing = true); // Show loading indicator

    try {
      // Create a payment intent on the server
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/stripe/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (widget.totalPrice * 100).toInt(), // Convert to cents
          'currency': 'usd',
          'eventId': widget.eventId,
          'seatCount': widget.seatCount,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final clientSecret =
            responseData['clientSecret']; // Retrieve client secret

        // Confirm the payment using Stripe
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(
                email: 'user@example.com', // Replace with user email
                name: widget.event['organizer'] ??
                    'Event Attendee', // Replace with user name
              ),
            ),
          ),
        );

        if (!mounted) return;

        // Navigate to the review summary page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewSummaryPage(
              event: widget.event,
              seatCount: widget.seatCount,
              totalPrice: widget.totalPrice,
              paymentMethod: 'Credit Card',
            ),
          ),
        );
      } else {
        throw Exception(
            'Payment failed: ${response.body}'); // Handle payment failure
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}')), // Show error message
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false); // Hide loading indicator
      }
    }
  }
}
