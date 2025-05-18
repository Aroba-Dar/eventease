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
  // Boolean to toggle between Login/Register mode
  bool isLogin = true;
  bool isAccepted = false;

  // Controllers to manage text inputs
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();

  // Dropdown selections
  String? selectedGender;
  String? selectedCountry;

  // API base URL
  final String apiBase = 'http://192.168.1.6:8081/users';

  // App primary color
  final Color primaryColor = const Color(0xFF9C27B0); // Logo purple color

  // Handle Login/Register button click
  void handleSubmit() async {
    // Validation for registration
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
        const SnackBar(
            content: Text("Please fill in all fields and accept terms")),
      );

      return;
    }

    // API endpoint for login/register
    String url = isLogin ? "$apiBase/login" : "$apiBase/register";

    // Payload based on login/register mode
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
      // API call
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      // Success
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save user details in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        if (data.containsKey('user_id')) {
          await prefs.setInt('userId', data['user_id']);
        }
        await prefs.setBool('isGuest', false);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString(
            'userName', '${data['firstName']} ${data['lastName']}');
        await prefs.setString('userEmail', data['email'] ?? '');
        await prefs.setInt('userId', data['user_id']);
        await prefs.setString('userPhone', data['phone'] ?? '');
        await prefs.setString('userCountry', data['country'] ?? '');
        await prefs.setString('firstName', data['firstName'] ?? '');
        await prefs.setString('lastName', data['lastName'] ?? '');
        await prefs.setString('gender', data['gender'] ?? 'male');

        // Navigation to Home Page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  isLogin ? "Login successful" : "Registration successful")),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Main body scrollable
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // App logo
            Center(
              child: Image.asset(
                'assets/images/app_logo.jpeg',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            // Welcome Text
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Welcome to ",
                    style: TextStyle(color: Colors.black, fontSize: 22),
                  ),
                  TextSpan(
                    text: "EventEase",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Dynamic heading based on login/register
            Text(
              isLogin ? "Login" : "Register",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            const SizedBox(height: 20),
            // Conditionally rendered Registration fields
            if (!isLogin) ...[
              _buildTextField("First Name", firstNameController),
              _buildTextField("Last Name", lastNameController),
              _buildDropdownField("Gender", ["Male", "Female"]),
              _buildDateField("Date of Birth", dobController),
              _buildTextField("Phone", phoneController),
              _buildDropdownField("Country", [
                "United States",
                "Canada",
                "Pakistan",
                "India",
                "Australia",
                "Germany",
                "France",
                "Italy",
                "Spain",
                "Japan",
                "China",
                "Russia",
                "South Africa",
                "New Zealand",
                "Sweden",
                "United Kingdom"
              ]),
            ],
            // Always rendered fields (Email & Password)
            _buildTextField("Email", emailController),
            _buildTextField("Password", passwordController, obscureText: true),
            // Accept Terms Checkbox
            if (!isLogin) _acceptTermsCheckbox(),
            const SizedBox(height: 20),
            // Submit Button
            _submitButton(),
            const SizedBox(height: 10),
            _toggleLoginRegister(),
            const SizedBox(height: 20),
            _guestLogin(),
          ],
        ),
      ),
    );
  }

  // Helper widget for text fields
  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          focusedBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 156, 39, 176), width: 2),
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Helper widget for dropdown fields
  Widget _buildDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
            hintText: label,
            focusedBorder: const OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 156, 39, 176)))),
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

  // Helper widget for date picker
  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today,
                size: 20, color: Color.fromARGB(255, 156, 39, 176)),
            focusedBorder: const OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 156, 39, 176)))),
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
      ),
    );
  }

  // Accept Terms Field
  Widget _acceptTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: isAccepted,
          onChanged: (value) {
            setState(() {
              isAccepted = value!;
            });
          },
          activeColor: primaryColor,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "I accept the ",
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: "Terms of Service and Privacy Policy",
                  style: TextStyle(
                      color: primaryColor,
                      decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Submit (Login/Register) Button
  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 3,
        side: BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 9),
      ),
      onPressed: handleSubmit,
      child: Text(
        isLogin ? "Login" : "Register",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
      ),
    );
  }

  // Toggle between Login & Register text
  Widget _toggleLoginRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(isLogin ? "Don't have an account? " : "Already have an account? "),
        GestureDetector(
          onTap: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: Text(
            isLogin ? "Register" : "Login",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Continue as Guest Option
  Widget _guestLogin() {
    return TextButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isGuest', true);
        await prefs.setBool('isLoggedIn', false);
        await prefs.setString('userName', 'Guest');
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Text(
        "Continue as Guest",
        style: TextStyle(
            color: primaryColor, fontSize: 17, fontWeight: FontWeight.w500),
      ),
    );
  }
}
