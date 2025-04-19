import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> addUser() async {
  final url = Uri.parse('http://localhost:8081/users/add');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': 'John Doe',
      'email': 'john@example.com',
      'password_hash': 'secret123',
      'phone': '1234567890',
      'user_type': 'user',
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('User added successfully: ${response.body}');
  } else {
    print('Failed to add user: ${response.statusCode}');
    print('Response: ${response.body}');
  }
}
