import 'package:flutter/material.dart';
import 'add_new_card_page.dart';
import 'review_summary_page.dart';

class PaymentSelectionPage extends StatefulWidget {
  const PaymentSelectionPage({super.key});

  @override
  _PaymentSelectionPageState createState() => _PaymentSelectionPageState();
}

class _PaymentSelectionPageState extends State<PaymentSelectionPage> {
  int _selectedPaymentMethod = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payments"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select the payment method you want to use.",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            _buildPaymentOption(1, "PayPal", Icons.account_balance_wallet),
            SizedBox(height: 10),
            _buildPaymentOption(2, "Google Pay", Icons.payment),
            SizedBox(height: 10),
            _buildPaymentOption(3, "Apple Pay", Icons.phone_iphone),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNewCardPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[100],
                foregroundColor: Colors.purple[700],
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Add New Card"),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReviewSummaryPage()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(int value, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: TextStyle(fontSize: 18)),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
