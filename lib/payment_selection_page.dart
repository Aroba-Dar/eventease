import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:event_ease/add_new_card_page.dart';
import 'package:event_ease/review_summary_page.dart';

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
  int _selectedPaymentMethod = 1;
  bool _isProcessing = false;
  final CardFormEditController _controller = CardFormEditController();

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey =
        'pk_test_51RHjJWIpuAYC0tEaNBS68cmQJJXfItuAONhWEpPSmqHrvRAwZvjynvFiVv4TvB3E7Ar5N4uoU1D7Wz5Y8tAyWM3v00ux1mE43p';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Text(
                    "Select the payment method you want to use.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  _buildPaymentOption(
                      1, "EasyPaisa", Icons.account_balance_wallet),
                  const SizedBox(height: 10),
                  _buildPaymentOption(2, "JazzCash", Icons.money),
                  const SizedBox(height: 10),
                  _buildPaymentOption(3, "Credit Card", Icons.credit_card),
                  const SizedBox(height: 20),
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
                          borderWidth: 2,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddNewCardPage()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[100],
                      foregroundColor: Colors.purple[700],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Add New Card"),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _handlePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Continue"),
                  ),
                ],
              ),
            ),
            if (_isProcessing)
              const ModalBarrier(
                dismissible: false,
                color: Colors.black54,
              ),
            if (_isProcessing)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(int value, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      trailing: Radio(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (int? newValue) {
          setState(() {
            _selectedPaymentMethod = newValue ?? 1;
          });
        },
        activeColor: Colors.purple,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      tileColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _handlePayment() {
    if (_selectedPaymentMethod == 1) {
      _showMockPaymentDialog("EasyPaisa");
    } else if (_selectedPaymentMethod == 2) {
      _showMockPaymentDialog("JazzCash");
    } else if (_selectedPaymentMethod == 3) {
      _makeStripePayment();
    }
  }

  void _showMockPaymentDialog(String methodName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$methodName Payment"),
        content: Text("Simulated payment successful via $methodName!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$methodName Payment Confirmed!")),
              );
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
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> _makeStripePayment() async {
    setState(() => _isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.6:8081/api/stripe/create-payment-intent'),
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
        final clientSecret = responseData['clientSecret'];

        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(
                email: 'user@example.com', // Get from user data
                name: widget.event['organizer'] ?? 'Event Attendee',
              ),
            ),
          ),
        );

        if (!mounted) return;

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
        throw Exception('Payment failed: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
