import 'package:event_ease/admin/admin_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SeatPricingPage extends StatefulWidget {
  final int eventId;
  final int organizerId;

  const SeatPricingPage({
    Key? key,
    required this.eventId,
    required this.organizerId,
  }) : super(key: key);

  @override
  _SeatPricingPageState createState() => _SeatPricingPageState();
}

class _SeatPricingPageState extends State<SeatPricingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _economyPriceController = TextEditingController();
  final TextEditingController _vipPriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _economySeatsController = TextEditingController();
  final TextEditingController _vipSeatsController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _economyPriceController.dispose();
    _vipPriceController.dispose();
    _discountController.dispose();
    _economySeatsController.dispose();
    _vipSeatsController.dispose();
    super.dispose();
  }

  // Submits seat pricing and availability data to backend
  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final Map<String, dynamic> seatData = {
        "eventId": widget.eventId,
        "economyPrice": double.parse(_economyPriceController.text),
        "vipPrice": double.parse(_vipPriceController.text),
        "economySeats": int.parse(_economySeatsController.text),
        "vipSeats": int.parse(_vipSeatsController.text),
      };

      if (_discountController.text.isNotEmpty) {
        seatData["discount"] = double.parse(_discountController.text);
      }

      try {
        final response = await http.post(
          Uri.parse("http://192.168.1.6:8081/api/seat-pricing"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(seatData),
        );

        print("Response Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Seat data submitted successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Submission failed: ${response.body}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Builds a styled input field for seat/pricing data
  Widget _buildInputCard({
    required String title,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: title,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Color.fromARGB(255, 156, 39, 176), width: 2),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $title' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Seat Pricing and Availability",
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromARGB(255, 156, 39, 176),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Section title for seat availability
              Text("Enter Seat Availability",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 10),
              // Row for economy and VIP seat count
              Row(
                children: [
                  Expanded(
                    child: _buildInputCard(
                      title: "Economy Seats",
                      hint: "50",
                      controller: _economySeatsController,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildInputCard(
                      title: "VIP Seats",
                      hint: "20",
                      controller: _vipSeatsController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Section title for seat pricing
              Text("Enter Seat Pricing",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              // Row for economy and VIP seat price
              Row(
                children: [
                  Expanded(
                    child: _buildInputCard(
                      title: "Economy Price",
                      hint: "\$100",
                      controller: _economyPriceController,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildInputCard(
                      title: "VIP Price",
                      hint: "\$200",
                      controller: _vipPriceController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Discount input (optional)
              _buildInputCard(
                title: "Discount (%) (optional)",
                hint: "Leave empty if no discount",
                controller: _discountController,
              ),
              SizedBox(height: 20),
              // Submit button or loading indicator
              _isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 156, 39, 176),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text("Upload Seat Information",
                          style: TextStyle(color: Colors.white)),
                    ),
              SizedBox(height: 30),
              // Button to go back to home page
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AdminHomePage(organizerId: widget.organizerId)));
                  // or use a custom HomeScreen()
                },
                icon: Icon(Icons.arrow_forward,
                    color: Color.fromARGB(255, 156, 39, 176)),
                label: Text(
                  'Go to Home Page',
                  style: TextStyle(
                    color: Color.fromARGB(255, 156, 39, 176),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
