import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_new_card_page.dart';
import 'review_summary_page.dart';

class PaymentSelectionPage extends StatefulWidget {
  const PaymentSelectionPage({super.key});

  @override
  _PaymentSelectionPageState createState() => _PaymentSelectionPageState();
}

class _PaymentSelectionPageState extends State<PaymentSelectionPage> {
  int _selectedPaymentMethod = 1;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                _buildPaymentOption(
                    3, "Credit Card (Stripe)", Icons.credit_card),
                const SizedBox(height: 20),
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
                const Spacer(),
                ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          if (_selectedPaymentMethod == 1) {
                            _showMockPaymentDialog("EasyPaisa");
                          } else if (_selectedPaymentMethod == 2) {
                            _showMockPaymentDialog("JazzCash");
                          } else if (_selectedPaymentMethod == 3) {
                            _makeStripePayment();
                          }
                        },
                  style: ElevatedButton.styleFrom(
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
        side: BorderSide(color: Colors.grey.shade200),
      ),
      tileColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
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
                MaterialPageRoute(builder: (context) => ReviewSummaryPage()),
              );
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> _makeStripePayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Step 1: Call your backend to create a PaymentIntent
      final response = await http.post(
        Uri.parse('http://192.168.1.6:8081/api/stripe/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 1000, // Amount in cents (1000 = $10.00)
          'currency': 'usd',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final paymentIntentClientSecret = responseData['clientSecret'];

        // Step 2: Confirm the payment using the clientSecret
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: paymentIntentClientSecret,
          data: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(
                email: 'customer@example.com',
                phone: '+1234567890',
                name: 'John Doe',
                address: Address(
                  city: 'New York',
                  country: 'US',
                  line1: '123 Main St',
                  line2: '',
                  postalCode: '10001',
                  state: 'NY',
                ),
              ),
            ),
          ),
        );

        // Step 3: Handle successful payment
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment successful!")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReviewSummaryPage()),
        );
      } else {
        throw Exception('Failed to create PaymentIntent: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: ${e.toString()}")),
      );
      debugPrint("Payment error: $e");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
