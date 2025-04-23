import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool isLogin = true;
  bool isAccepted = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();

  String? selectedGender;
  String? selectedCountry;

  final String apiBase = 'http://192.168.1.6:8081/users';

  void handleSubmit() async {
    if (!isLogin &&
        (emailController.text.isEmpty ||
            passwordController.text.isEmpty ||
            firstNameController.text.isEmpty ||
            lastNameController.text.isEmpty ||
            dobController.text.isEmpty ||
            phoneController.text.isEmpty ||
            selectedGender == null ||
            selectedCountry == null ||
            !isAccepted)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields and accept terms")),
      );
      return;
    }

    String url = isLogin ? "$apiBase/login" : "$apiBase/register";
    final Map<String, dynamic> payload = isLogin
        ? {
            'email': emailController.text,
            'password': passwordController.text,
          }
        : {
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
            'email': emailController.text,
            'password': passwordController.text,
            'gender': selectedGender,
            'country': selectedCountry,
            'phone': phoneController.text,
            'dateOfBirth': dobController.text,
            'isGuest': false,
            'acceptedTerms': isAccepted,
          };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGuest', false);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', data['email'] ?? '');
        await prefs.setString('firstName', data['firstName'] ?? '');
        await prefs.setString('lastName', data['lastName'] ?? '');
        await prefs.setString('gender', data['gender'] ?? 'Male');
        await prefs.setString('country', data['country'] ?? '');
        await prefs.setString('phone', data['phone'] ?? '');
        await prefs.setString('dateOfBirth', data['dateOfBirth'] ?? '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  isLogin ? "Login successful" : "Registration successful")),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!isLogin) ...[
              _buildTextField("First Name", firstNameController),
              _buildTextField("Last Name", lastNameController),
              _buildDropdownField("Gender", ["Male", "Female"]),
              _buildDateField("Date of Birth", dobController),
              _buildTextField("Phone", phoneController),
              _buildDropdownField("Country", ["United States", "Canada", "UK"]),
            ],
            _buildTextField("Email", emailController),
            _buildTextField("Password", passwordController, obscureText: true),
            if (!isLogin)
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleSubmit,
              child: Text(isLogin ? "Login" : "Register"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(isLogin
                  ? "Don't have an account? Register"
                  : "Already have an account? Login"),
            ),
            Divider(height: 30),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isGuest', true);
                await prefs.setBool('isLoggedIn', false);
                await prefs.setString('firstName', 'Guest');
                await prefs.setString('gender', 'Male');
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text("Continue as Guest"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
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
        items: options
            .map((option) =>
                DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
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
