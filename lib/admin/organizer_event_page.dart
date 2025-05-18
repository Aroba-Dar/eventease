import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model class for an event
class Event {
  final int id;
  final String title;
  final String dateTime;
  final String location;
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.imageUrl,
  });

  // Factory constructor to create Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      dateTime: json['dateTime'],
      location: json['location'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class OrganizerEventsPage extends StatefulWidget {
  final int organizerId;

  const OrganizerEventsPage({super.key, required this.organizerId});

  @override
  _OrganizerEventsPageState createState() => _OrganizerEventsPageState();
}

class _OrganizerEventsPageState extends State<OrganizerEventsPage> {
  late Future<List<Event>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = fetchEventsByOrganizer(widget.organizerId);
  }

  // Fetches events for the given organizer from the backend
  Future<List<Event>> fetchEventsByOrganizer(int organizerId) async {
    final url =
        Uri.parse('http://192.168.1.6:8081/events/by-organizer/$organizerId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Displays a list of events using FutureBuilder
      body: FutureBuilder<List<Event>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while waiting for data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if fetching fails
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show message if no events found
            return const Center(child: Text('No events found.'));
          }

          final events = snapshot.data!;
          // Build a list of event cards
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: event.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: event.imageUrl.startsWith('data:image') ||
                                  event.imageUrl.length > 100
                              ? Image.memory(
                                  base64Decode(
                                    event.imageUrl.replaceAll(
                                        RegExp(r'data:image/[^;]+;base64,'),
                                        ''),
                                  ),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  event.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.grey),
                                  ),
                                ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.event, color: Colors.grey),
                        ),
                  title: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.dateTime,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 156, 39, 176)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14,
                              color: Color.fromARGB(255, 156, 39, 176)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
