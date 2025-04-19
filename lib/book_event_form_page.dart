import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookEventPage extends StatefulWidget {
  const BookEventPage({super.key});

  @override
  _BookEventPageState createState() => _BookEventPageState();
}

class _BookEventPageState extends State<BookEventPage> {
  bool isAccepted = false;

  // Controllers
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? selectedGender;
  String? selectedCountry;

  // Replace this with your backend URL
  final String apiUrl = 'http://10.109.40.45:8081/booking-form/add';

  Future<void> _submitForm() async {
    final Map<String, dynamic> userData = {
      "firstName": _nameController.text,
      "lastName": _lastNameController.text,
      "gender": selectedGender,
      "dateOfBirth": _dobController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "country": selectedCountry,
      "acceptedTerms": isAccepted
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User registered successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to register: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Event", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField("Full Name", "Andrew", _nameController),
            _buildTextField("Last Name", "Ainsley", _lastNameController),
            _buildDropdownField("Gender", ["Male", "Female"]),
            _buildDateField("Date of Birth", _dobController),
            _buildTextField("Email", "andrew@example.com", _emailController),
            _buildTextField("Phone Number", "+123456789", _phoneController),
            _buildDropdownField("Country", ["United States", "Canada", "UK"]),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isAccepted,
                  onChanged: (value) {
                    setState(() {
                      isAccepted = value!;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "I accept the ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Terms of Service and Privacy Policy",
                          style: TextStyle(color: Colors.blue),
                        ),
                        TextSpan(text: " (Required)"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isAccepted ? _submitForm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAccepted ? Colors.blueAccent : Colors.grey,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String placeholder, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: (value) {
          setState(() {
            if (label == "Gender") selectedGender = value!;
            if (label == "Country") selectedCountry = value!;
          });
        },
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            controller.text = "${pickedDate.toLocal()}".split(' ')[0];
          }
        },
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
