import 'dart:convert';
import 'package:event_ease/event_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'category.dart';

class PopularEventsPage extends StatefulWidget {
  const PopularEventsPage({super.key});

  @override
  _PopularEventsPageState createState() => _PopularEventsPageState();
}

class _PopularEventsPageState extends State<PopularEventsPage> {
  // List to store fetched events
  List<dynamic> events = [];
  // Currently selected category for filtering events
  String selectedCategory = 'All';
  // Loading state to show a progress indicator while fetching data
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch events when the widget is initialized
    fetchEvents();
  }

  // Method to fetch events from the server
  Future<void> fetchEvents() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.6:8081/events'));
      // chexk organizer id is present or not

      if (response.statusCode == 200) {
        // Parse the response body and update the state
        final List<dynamic> eventList = json.decode(response.body);

        setState(() {
          events = eventList;
          isLoading = false;
        });
      } else {
        // Handle error response
        setState(() => isLoading = false);
        throw Exception('Failed to load events');
      }
    } catch (e) {
      // Handle network or parsing errors
      setState(() => isLoading = false);
      print('Error fetching events: $e');
    }
  }

  // Method to handle image rendering based on URL type
  Widget buildImage(String imageUrl) {
    // Check if imageUrl starts with "http" or "https"
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
      );
    }

    // Otherwise, assume it's base64
    try {
      final base64Str = imageUrl.split(',').last; // Remove prefix if any
      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
      );
    } catch (e) {
      return const Icon(Icons.broken_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter events based on the selected category
    final List<dynamic> displayedEvents = selectedCategory == 'All'
        ? events
        : events.where((e) => e['category'] == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Popular Events",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // CategoryBar widget for selecting event categories
                  CategoryBar(
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // GridView to display events in a grid layout
                  Expanded(
                    child: GridView.builder(
                      itemCount: displayedEvents.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        mainAxisSpacing: 12, // Vertical spacing
                        crossAxisSpacing: 12, // Horizontal spacing
                        childAspectRatio: 0.7, // Aspect ratio of grid items
                      ),
                      itemBuilder: (context, index) {
                        final event = displayedEvents[index];
                        // Render each event as an EventCard
                        return EventCard(event: event, buildImage: buildImage);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// StatelessWidget to display individual event details in a card
class EventCard extends StatelessWidget {
  final dynamic event;
  final Widget Function(String) buildImage;

  const EventCard({super.key, required this.event, required this.buildImage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to EventDetailsPage when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsPage(
              event: {
                'id': event['id'],
                'name': event['title'] ?? '',
                'category': event['category'] ?? '',
                'date': event['dateTime']?.split('.')[0] ?? '',
                'time': event['dateTime']?.split('.')[1] ?? '',
                'location': event['location'] ?? '',
                'imageUrl': event['imageUrl'] ?? '',
                'organizerId': event['organizerId'] ?? '',
                'description': event['description'] ?? '',
                'organizerName': event['organizer'] ?? '', // Organizer's name
                'organizerImage':
                    event['organizerImage'] ?? '', // Organizer's image
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 4, // Shadow depth of the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display event image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: buildImage(event['imageUrl'] ?? ''),
              ),
            ),
            // Display event title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                event['title'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Display event date and time
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                event['dateTime'] ?? '',
                style:
                    const TextStyle(color: Color.fromARGB(255, 156, 39, 176)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
