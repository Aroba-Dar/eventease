import 'dart:convert';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:event_ease/book_event_form_page.dart';
import 'package:event_ease/seat_count_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as location;
import 'package:intl/intl.dart';

// Main Event Details Page
class EventDetailsPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage>
    with WidgetsBindingObserver {
  late Future<bool> _isFavFuture; // Future to check if the event is a favorite
  location.LocationData? _currentLocation; // Stores the user's current location

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observe app lifecycle changes
    _isFavFuture = _isFavorite(); // Initialize favorite status
    _getCurrentLocation(); // Fetch user's current location
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer on dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh location when the app resumes
    if (state == AppLifecycleState.resumed) {
      _getCurrentLocation();
    }
  }

  // Fetch user's current location
  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission
      final permission = await Permission.locationWhenInUse.request();
      if (!permission.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission not granted")),
        );
        return;
      }

      location.Location locationService = location.Location();
      bool serviceEnabled = await locationService.serviceEnabled();
      if (!serviceEnabled) {
        // Request to enable location service
        serviceEnabled = await locationService.requestService();
        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location service not enabled")),
          );
          return;
        }
      }

      // Get the current location
      final locationData = await locationService.getLocation();
      if (mounted) {
        setState(() {
          _currentLocation = locationData;
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // Launch Google Maps with directions to the event location
  void _launchMaps(String destination) async {
    final destinationEncoded = Uri.encodeComponent(destination);
    final origin = _currentLocation != null
        ? "${_currentLocation!.latitude},${_currentLocation!.longitude}"
        : "";
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$destinationEncoded&origin=$origin&travelmode=driving";

    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open maps")),
        );
      }
    } catch (e) {
      print("Error launching map: $e");
    }
  }

  // Handle event booking logic
  Future<void> _handleBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? true;

    if (isGuest) {
      // Navigate to booking form for guest users
      final formSuccess = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => BookEventPage(event: widget.event),
        ),
      );
      if (formSuccess == true) {
        final eventId = widget.event['id'];

        if (eventId == null || eventId is! int) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event ID is missing or invalid')),
          );
          return;
        }

        // Navigate to seat booking page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookEventSeatPage(
              event: widget.event,
              eventId: eventId,
            ),
          ),
        );
      }
    } else {
      // Directly navigate to seat booking page for logged-in users
      final eventId = widget.event['id'];

      if (eventId == null || eventId is! int) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event ID is missing or invalid')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookEventSeatPage(
            event: widget.event,
            eventId: eventId,
          ),
        ),
      );
    }
  }

  // Add event to the user's calendar
  Future<void> _addToCalendar() async {
    // Request calendar permission
    final status = await Permission.calendar.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Calendar permission not granted")),
      );
      return;
    }

    final event = widget.event;
    final title = event['name'] ?? 'Event';
    final description = event['description'] ?? '';
    final location = event['location'] ?? '';
    final rawDate = event['date'] ?? '';
    final rawTime = event['time'] ?? '';

    DateTime? startDate;
    try {
      // Parse date and time
      final currentYear = DateTime.now().year;
      final parsedDate = DateFormat('EEE, MMM d').parse(rawDate);
      final fullDate = DateTime(currentYear, parsedDate.month, parsedDate.day);

      final timeRange = rawTime.split('-').first.trim();
      final parsedTime = DateFormat('hh:mm').parse(timeRange);

      startDate = DateTime(
        fullDate.year,
        fullDate.month,
        fullDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      print("Parsing error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid date or time format")),
      );
      return;
    }

    // Create calendar event
    final calendarEvent = Event(
      title: title,
      description: description,
      location: location,
      startDate: startDate,
      endDate: startDate.add(const Duration(hours: 2)),
      iosParams: const IOSParams(
        reminder: Duration(minutes: 30),
        url: 'https://example.com',
      ),
      androidParams: const AndroidParams(
        emailInvites: [],
      ),
    );

    try {
      await Add2Calendar.addEvent2Cal(calendarEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event added to calendar")),
      );
    } catch (e) {
      print("Calendar error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add event to calendar")),
      );
    }
  }

  // Toggle favorite status of the event
  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('email');
    final userId = prefs.getInt('userId');
    final eventId = widget.event['id'];

    if (userEmail == null || userId == null || eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID, email or Event ID missing.')),
      );
      return;
    }

    final String url = 'http://192.168.1.6:8081/favorites/toggle';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'eventId': eventId,
        }),
      );

      if (response.statusCode == 200) {
        final message = response.body;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));

        // Update favorite status in the UI
        setState(() {
          _isFavFuture =
              Future.value(message == 'Favorite added.' ? true : false);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to toggle favorite: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error updating favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating favorite.')),
      );
    }
  }

  // Check if the event is marked as a favorite
  Future<bool> _isFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('email');
    final favoriteKey = 'favorites_$userEmail';
    List<String> favorites = prefs.getStringList(favoriteKey) ?? [];
    return favorites.contains(widget.event['id'].toString());
  }

  // Build image widget for event images
  Widget _buildImage(dynamic imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
      );
    } else {
      return Image.asset(
        "assets/images/notfound.png",
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: CarouselSlider(
                    options: CarouselOptions(height: 300, autoPlay: true),
                    items: [(event['imageUrl'] ?? '')]
                        .map<Widget>(_buildImage)
                        .toList(),
                  ),
                ),
              ),
            ],
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title
                  Text(event['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Event category chip
                  Chip(
                    label: Text(event['category'] ?? ''),
                    side: BorderSide(
                      color: Color.fromARGB(255, 156, 39,
                          176), // Change this to your desired border color
                      width: 1.0, // Adjust border width as needed
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Event date and time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color.fromARGB(255, 156, 39, 176)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event['date'] ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(event['time'] ?? ''),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _addToCalendar,
                        child: const Text("Add to Calendar",
                            style: TextStyle(
                                color: Color.fromARGB(255, 156, 39, 176))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Event location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(event['location'] ?? '')),
                      ElevatedButton(
                        onPressed: () => _launchMaps(event['location'] ?? ''),
                        child: const Text("Get Directions",
                            style: TextStyle(
                                color: Color.fromARGB(255, 156, 39, 176))),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  // Organizer details
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: event['organizerImage'] != null &&
                              event['organizerImage'].isNotEmpty
                          ? NetworkImage(event['organizerImage'])
                          : const AssetImage("assets/images/organizer.jpg")
                              as ImageProvider,
                    ),
                    title: Text(
                      event['organizerName'] ?? 'Organizer Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Organizer"),
                  ),
                  const Divider(),
                  // About the event
                  const Text("About Event",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(event['description'] ?? 'No description available.'),
                  const SizedBox(height: 16),
                  // Event gallery
                  const Text("Gallery (Pre-Event)",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        "assets/images/event1.jpg",
                        "assets/images/event2.jpg",
                        "assets/images/event3.jpg",
                      ]
                          .map((img) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    img,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Favorite button
          Positioned(
            top: 40,
            right: 16,
            child: Row(
              children: [
                FutureBuilder<bool>(
                  future: _isFavFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error, color: Colors.grey);
                    }

                    final isFavorite = snapshot.data ?? false;
                    return GestureDetector(
                      onTap: _toggleFavorite,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation bar for booking
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: _handleBooking,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Color.fromARGB(255, 156, 39, 176),
          ),
          child: const Text("Book Event",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
