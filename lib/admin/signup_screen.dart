import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController contactNumberCtrl = TextEditingController();
  TextEditingController dobCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  TextEditingController countryCtrl = TextEditingController();

  String? selectedGender;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final Color primaryColor = const Color.fromARGB(255, 156, 39, 176);

  // Pick profile image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Pick date of birth using date picker
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dobCtrl.text = "${picked.toLocal()}".split(' ')[0]; // yyyy-mm-dd
      });
    }
  }

  // Register organizer by sending data to backend
  Future<void> _registerOrganizer() async {
    if (!_formKey.currentState!.validate()) return;

    String? base64Image;
    if (_imageFile != null) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    } else {
      base64Image = null;
    }

    final url = Uri.parse('http://localhost:8080/organizers/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'organizerName': nameCtrl.text,
        'profileImage': base64Image, // base64 string or null
        'email': emailCtrl.text,
        'gender': selectedGender,
        'contactNumber': contactNumberCtrl.text,
        'dob': dobCtrl.text,
        'password': passwordCtrl.text,
        'country': countryCtrl.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup successful! Please login.')));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } else if (response.statusCode == 409) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Email already registered!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed. Please try again.')));
    }
  }

  // Input decoration for form fields
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Signup', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile image picker
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Tap above to select profile image'),
              const SizedBox(height: 20),

              // Organizer name input
              TextFormField(
                controller: nameCtrl,
                decoration: _inputDecoration('Organizer Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter name';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Email input
              TextFormField(
                controller: emailCtrl,
                decoration: _inputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Gender dropdown
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Gender'),
                value: selectedGender,
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select gender' : null,
              ),
              const SizedBox(height: 15),

              // Contact number input
              TextFormField(
                controller: contactNumberCtrl,
                decoration: _inputDecoration('Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Date of Birth with date picker
              TextFormField(
                controller: dobCtrl,
                readOnly: true,
                decoration:
                    _inputDecoration('Date of Birth (YYYY-MM-DD)').copyWith(
                  hintText: 'e.g. 1990-01-01',
                  suffixIcon: Icon(Icons.calendar_today, color: primaryColor),
                ),
                onTap: _pickDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Password input
              TextFormField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: _inputDecoration('Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  if (value.length < 6) {
                    return 'Password should be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Country input
              TextFormField(
                controller: countryCtrl,
                decoration: _inputDecoration('Country'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter country';
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Signup button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _registerOrganizer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
