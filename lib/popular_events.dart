import 'dart:convert';
import 'package:event_ease/event_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'category.dart'; // make sure this is the updated one

class PopularEventsPage extends StatefulWidget {
  const PopularEventsPage({super.key});

  @override
  _PopularEventsPageState createState() => _PopularEventsPageState();
}

class _PopularEventsPageState extends State<PopularEventsPage> {
  List<dynamic> events = [];
  String selectedCategory = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final response = await http.get(Uri.parse('http://10.20.6.65:8081/events'));

    if (response.statusCode == 200) {
      final List<dynamic> eventList = json.decode(response.body);

      setState(() {
        events = eventList;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception('Failed to load events');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> displayedEvents = selectedCategory == 'All'
        ? events
        : events.where((e) => e['category'] == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Popular Events"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CategoryBar(
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      itemCount: displayedEvents.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final event = displayedEvents[index];
                        return EventCard(event: event);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class EventCard extends StatelessWidget {
  final dynamic event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsPage(
              event: {
                'name': event['title'] ?? '',
                'category': event['category'] ?? '',
                'date': event['dateTime']?.split(' ')[0] ?? '',
                'time': event['dateTime']?.split(' ')[1] ?? '',
                'location': event['location'] ?? '',
                'imageUrl': event['imageUrl'] ?? '',
                'description': event['description'] ?? '',
                'organizerName':
                    event['organizerName'] ?? '', // Add organizer name
                'organizerImage':
                    event['profileImage'] ?? '', // Add organizer image
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  event['imageUrl'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                event['title'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                event['dateTime'] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
