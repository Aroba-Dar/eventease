import 'dart:convert';
import 'package:event_ease/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/event.dart';
import 'popular_events.dart';
import 'category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String greeting = '';
  String displayName = 'Guest';
  String gender = 'male';
  bool isGuest = true;
  String selectedCategory = 'All';
  List<Event> allEvents = [];

  @override
  void initState() {
    super.initState();
    loadUserSession();
    fetchEvents();
  }

  DateTime? parseCustomDate(String dateString) {
    try {
      // Example format: "Mon, Jun 3 . 14:00 - 18:00 PM"
      final parts = dateString.split(' . ');
      if (parts.length != 2) return null;

      final datePart = parts[0]; // "Mon, Jun 3"
      final timePart = parts[1].split(' - ')[0]; // "14:00"

      final now = DateTime.now();
      final year = now.year;

      // Parse month and day from "Jun 3"
      final dateParts = datePart.split(', ')[1].split(' ');
      final monthStr = dateParts[0]; // "Jun"
      final day = int.parse(dateParts[1]); // 3

      // Parse time from "14:00"
      final timeParts = timePart.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Convert month string to number
      const months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12
      };

      final month = months[monthStr] ?? 1;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final guest = prefs.getBool('isGuest') ?? true;

    setState(() {
      isGuest = guest;
    });

    if (!isGuest && savedEmail != null) {
      fetchUserData(savedEmail);
    } else {
      setGuestUser();
    }
  }

  void setGuestUser() {
    setState(() {
      greeting = getGreeting();
      displayName = 'Guest';
      gender = 'male';
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 👋';
  }

  Future<void> fetchUserData(String email) async {
    final url = Uri.parse('http://192.168.1.6:8081/users/email/$email');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        setState(() {
          greeting = getGreeting();
          displayName = '${user['firstName']} ${user['lastName']}';
          gender = user['gender'] ?? 'male';
        });
      } else {
        setGuestUser();
      }
    } catch (e) {
      setGuestUser();
    }
  }

  Future<void> fetchEvents() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.6:8081/events'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        allEvents = data.map((e) => Event.fromJson(e)).toList();
      });
    }
  }

  List<Event> getFilteredEvents() {
    if (selectedCategory == 'All') return allEvents;
    return allEvents
        .where(
            (e) => e.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
  }

  List<Event> getFeaturedEvents() {
    // Create a list of events with parsed dates
    final eventsWithDates = allEvents.map((event) {
      final parsedDate = parseCustomDate(event.dateTime);
      return {
        'event': event,
        'date': parsedDate,
        'isValid': parsedDate != null
      };
    }).toList();

    // Filter out events with invalid dates and sort by date proximity
    final validEvents =
        eventsWithDates.where((e) => e['isValid'] as bool).toList();

    validEvents.sort((a, b) {
      final now = DateTime.now();
      final aDate = a['date'] as DateTime;
      final bDate = b['date'] as DateTime;
      return aDate.difference(now).abs().compareTo(bDate.difference(now).abs());
    });

    // Return only the first 4 valid events (closest to now)
    return validEvents.take(4).map((e) => e['event'] as Event).toList();
  }

  Widget _buildProfileAvatar() {
    String imageAsset = gender == 'male'
        ? 'assets/images/male.jpeg'
        : 'assets/images/female.jpeg';
    return CircleAvatar(
      backgroundImage: AssetImage(imageAsset),
      radius: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = getFilteredEvents();
    final featuredEvents = getFeaturedEvents();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile & Notification Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildProfileAvatar(),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greeting,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14)),
                          Text(displayName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.notifications_none, color: Colors.black87),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('What event are you looking for...',
                        style: TextStyle(color: Colors.grey)),
                    Icon(Icons.filter_list, color: Colors.black87),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Featured Header
              const Text('Featured',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Featured Events (Closest to current date/time)
              SizedBox(
                height: 320,
                child: featuredEvents.isEmpty
                    ? const Center(child: Text('No upcoming events'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredEvents.length,
                        itemBuilder: (context, index) {
                          final event = featuredEvents[index];
                          return Container(
                            width: 260,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 5)
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.network(
                                    event.imageUrl,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                                height: 140,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(event.title,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(event.dateTime,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 14, color: Colors.blue),
                                          const SizedBox(width: 4),
                                          Text(event.location,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),

              // Popular Events Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Text('Popular Event ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 18),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PopularEventsPage()),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🔥 Dynamic Categories
              CategoryBar(
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Popular Event Cards (Filtered)
              filteredEvents.isEmpty
                  ? const Center(child: Text('No events in this category'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 3)
                            ],
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
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
                                            color: Colors.grey)),
                              ),
                            ),
                            title: Text(event.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event.dateTime,
                                    style: const TextStyle(color: Colors.blue)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 14, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text(event.location,
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onTap: (index) {
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            }
          },
        ),
      ),
    );
  }
}
