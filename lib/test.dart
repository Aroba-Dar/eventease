import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DatabaseTestPage extends StatefulWidget {
  const DatabaseTestPage({super.key});

  @override
  _DatabaseTestPageState createState() => _DatabaseTestPageState();
}

class _DatabaseTestPageState extends State<DatabaseTestPage> {
  String status = "Checking...";

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse("http://10.109.40.50:8080/event_ease/get_events.php"));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          status = "Connected: ${data.length} records found";
        });
      } else {
        setState(() {
          status = "Failed: Status ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Database Test")),
      body: Center(child: Text(status)),
    );
  }
}
