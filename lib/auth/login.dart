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
  final Color primaryColor = const Color(0xFF9C27B0); // Logo purple color

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
        // ✅ Safely parse and store user_id
        if (data.containsKey('user_id')) {
          await prefs.setInt('userId', data['user_id']);
          print("Saved user_id to prefs: ${data['user_id']}");
        } else {
          print("⚠️ 'user_id' not found in response");
        }
        await prefs.setBool('isGuest', false);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString(
            'userName', '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}');
        await prefs.setString('userEmail', data['email'] ?? '');
        await prefs.setString('userPhone', data['phone'] ?? '');
        await prefs.setString('firstName', data['firstName'] ?? '');
        await prefs.setString('lastName', data['lastName'] ?? '');
        await prefs.setString('gender', data['gender'] ?? 'Male');
        await prefs.setString('country', data['country'] ?? '');
        await prefs.setString('dateOfBirth', data['dateOfBirth'] ?? '');
        // await prefs.setInt('userId', data['user_id']);

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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Center(
              child: Image.asset(
                'assets/images/app_logo.jpeg',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Welcome to ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: "EventEase",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto', // or any font you prefer
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "A smart ticketing app",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              isLogin ? "Login" : "Register",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            if (!isLogin) ...[
              _buildTextField("First Name", firstNameController),
              _buildTextField("Last Name", lastNameController),
              _buildDropdownField("Gender", ["Male", "Female"]),
              _buildDateField("Date of Birth", dobController),
              _buildTextField("Phone", phoneController),
              _buildDropdownField(
                  "Country", ["United States", "Canada", "United Kingdom"]),
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
                    activeColor: primaryColor,
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
                                color: primaryColor,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(text: " (Required)"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.white,
                elevation: 3,
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 19, vertical: 9),
              ),
              onPressed: handleSubmit,
              child: Text(
                isLogin ? "Login" : "Register",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin
                      ? "Don't have an account? "
                      : "Already have an account? ",
                  style: const TextStyle(color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin ? "Register" : "Login",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(
              thickness: 1,
              color: Colors.grey.shade500,
              height: 20,
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isGuest', true);
                await prefs.setBool('isLoggedIn', false);
                await prefs.setString('userName', 'Guest');
                await prefs.setString('userEmail', '');
                await prefs.setString('userPhone', '');
                await prefs.setString('gender', 'Male');
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text(
                "Continue as Guest",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
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
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
          suffixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
