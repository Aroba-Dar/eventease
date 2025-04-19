import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _phone = '';
  String _userType = 'user';

  Future<void> registerUser() async {
    var url = Uri.parse('http://192.168.1.6:8080/event_ease/register.php');

    Map<String, String> data = {
      'name': _name,
      'email': _email,
      'password': _password,
      'phone': _phone,
      'user_type': _userType,
    };

    var body = json.encode(data);

    var response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    print('Response: ${response.body}');
    var responseData = json.decode(response.body);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(responseData.containsKey('success') ? 'Success' : 'Error'),
        content: Text(responseData['success'] ?? responseData['error']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
                onChanged: (value) => _name = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty || !value.contains('@')
                    ? 'Enter valid email'
                    : null,
                onChanged: (value) => _email = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Enter password' : null,
                onChanged: (value) => _password = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter phone number' : null,
                onChanged: (value) => _phone = value,
              ),
              DropdownButtonFormField<String>(
                value: _userType,
                onChanged: (value) => setState(() => _userType = value!),
                items: ['user', 'organizer']
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                decoration: InputDecoration(labelText: 'User Type'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) registerUser();
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
