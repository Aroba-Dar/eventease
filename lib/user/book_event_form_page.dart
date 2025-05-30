import 'package:event_ease/user/seat_count_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookEventPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const BookEventPage({super.key, required this.event});

  @override
  _BookEventPageState createState() => _BookEventPageState();
}

class _BookEventPageState extends State<BookEventPage> {
  bool isAccepted = false;

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? selectedGender;
  String? selectedCountry;

  final String apiUrl = 'http://localhost:8080/users/register';

  Future<void> _submitForm() async {
    final Map<String, dynamic> userData = {
      "firstName": _nameController.text,
      "lastName": _lastNameController.text,
      "gender": selectedGender,
      "dateOfBirth": _dobController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "password": _passwordController.text,
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
        // ignore: unused_local_variable
        final data = jsonDecode(response.body);

        // Save user details to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGuest', false);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString(
            'userName', '${_nameController.text} ${_lastNameController.text}');
        await prefs.setString('userEmail', _emailController.text);
        await prefs.setString('userPhone', _phoneController.text);
        await prefs.setString('firstName', _nameController.text);
        await prefs.setString('lastName', _lastNameController.text);
        await prefs.setString('gender', selectedGender ?? 'Male');
        await prefs.setString('country', selectedCountry ?? '');
        await prefs.setString('dateOfBirth', _dobController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration successful!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookEventSeatPage(
                event: widget.event, eventId: widget.event['id']),
          ),
        );
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

  // Rest of the code remains the same...
  @override
  Widget build(BuildContext context) {
    final eventName = widget.event['name'] ?? "Book Event";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(eventName, style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 156, 39, 176),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
            _buildTextField("Password", "********", _passwordController,
                obscureText: true),
            _buildDropdownField("Country", [
              "United States",
              "Canada",
              "UK",
              "Australia",
              "India",
              "Pakistan",
              "Bangladesh",
              "Germany",
              "France",
              "Italy"
            ]),
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
                          style: TextStyle(
                              color: Color.fromARGB(255, 156, 39, 176)),
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
                backgroundColor: isAccepted
                    ? Color.fromARGB(255, 156, 39, 176)
                    : Colors.grey,
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

  // Rest of the helper methods remain the same...
  Widget _buildTextField(
      String label, String placeholder, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Color.fromARGB(255, 156, 39, 176),
          )),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
            labelText: label,
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color.fromARGB(255, 156, 39, 176)))),
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
          suffixIcon: Icon(Icons.calendar_today,
              color: Color.fromARGB(255, 156, 39, 176)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Color.fromARGB(255, 156, 39, 176),
          )),
        ),
      ),
    );
  }
}
