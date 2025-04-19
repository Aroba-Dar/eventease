import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  List<dynamic> _users = [];

  Future<void> fetchUsers() async {
    var url = Uri.parse(
        'http://192.168.1.6:8080/event_ease/get_users.php'); // Adjust the URL to your PHP script path

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      if (responseData['success']) {
        setState(() {
          _users = responseData['users'];
        });
      } else {
        // Handle error when no users are found
        print('Error: ${responseData['message']}');
      }
    } else {
      print('Failed to load users');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users List')),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          var user = _users[index];
          return ListTile(
            title: Text(user['name']),
            subtitle: Text(user['email']),
            trailing: Text(user['user_type']),
          );
        },
      ),
    );
  }
}
