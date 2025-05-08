import 'dart:convert';
import 'package:event_ease/event_detail_page.dart';
import 'package:event_ease/favourite_page.dart';
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
  // Variables for user session and UI state
  String greeting = '';
  String displayName = 'Guest';
  String gender = 'male';
  bool isGuest = true;
  String selectedCategory = 'All';
  List<Event> allEvents = [];
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load user session and fetch events when the widget is initialized
    loadUserSession();
    fetchEvents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Clean up the search controller when the widget is disposed
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Listener for search bar text changes
  void _onSearchChanged() {
    setState(() {
      isSearching = _searchController.text.isNotEmpty;
    });
  }

  // Filter events based on the search query
  List<Event> _filterEvents(String query) {
    return allEvents.where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase()) ||
          event.location.toLowerCase().contains(query.toLowerCase()) ||
          event.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Parse custom date format from event data
  DateTime? parseCustomDate(String dateString) {
    try {
      final parts = dateString.split(' . ');
      if (parts.length != 2) return null;

      final datePart = parts[0];
      final timePart = parts[1].split(' - ')[0];

      final now = DateTime.now();
      final year = now.year;

      final dateParts = datePart.split(', ')[1].split(' ');
      final monthStr = dateParts[0];
      final day = int.parse(dateParts[1]);

      final timeParts = timePart.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

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

  // Load user session data from shared preferences
  Future<void> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? true;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final email = prefs.getString('userEmail');

    setState(() {
      this.isGuest = isGuest;
    });

    if (!isGuest && isLoggedIn && email != null) {
      final firstName = prefs.getString('firstName');
      final lastName = prefs.getString('lastName');
      final savedGender = prefs.getString('gender');

      if (firstName != null && lastName != null) {
        setState(() {
          greeting = getGreeting();
          displayName = '$firstName $lastName';
          gender = savedGender ?? 'male';
        });
      } else {
        await fetchUserData(email);
      }
    } else {
      setGuestUser();
    }
  }

  // Set default guest user data
  void setGuestUser() {
    setState(() {
      greeting = getGreeting();
      displayName = 'Guest';
      gender = 'male';
    });
  }

  // Generate a greeting message based on the time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 👋';
  }

  // Fetch user data from the server
  Future<void> fetchUserData(String email) async {
    final url = Uri.parse('http://192.168.1.6:8081/users/email/$email');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('firstName', user['firstName'] ?? '');
        await prefs.setString('lastName', user['lastName'] ?? '');
        await prefs.setString('gender', user['gender'] ?? 'male');

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

  // Fetch events from the server
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

  // Get events filtered by the selected category
  List<Event> getFilteredEvents() {
    if (selectedCategory == 'All') return allEvents;
    return allEvents
        .where(
            (e) => e.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
  }

  // Get featured events sorted by their proximity to the current date
  List<Event> getFeaturedEvents() {
    final eventsWithDates = allEvents.map((event) {
      final parsedDate = parseCustomDate(event.dateTime);
      return {
        'event': event,
        'date': parsedDate,
        'isValid': parsedDate != null
      };
    }).toList();

    final validEvents =
        eventsWithDates.where((e) => e['isValid'] as bool).toList();

    validEvents.sort((a, b) {
      final now = DateTime.now();
      final aDate = a['date'] as DateTime;
      final bDate = b['date'] as DateTime;
      return aDate.difference(now).abs().compareTo(bDate.difference(now).abs());
    });

    return validEvents.take(4).map((e) => e['event'] as Event).toList();
  }

  // Build the profile avatar widget
  Widget _buildProfileAvatar() {
    String imageAsset = gender.toLowerCase() == 'female'
        ? 'assets/images/female.jpeg'
        : 'assets/images/male.jpeg';
    return CircleAvatar(
      backgroundImage: AssetImage(imageAsset),
      radius: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine which events to display based on search or category
    final eventsToDisplay = isSearching
        ? _filterEvents(_searchController.text)
        : getFilteredEvents();
    final featuredEvents = getFeaturedEvents();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Row
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
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'What event are you looking for...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Search functionality is handled by the listener
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Featured Events (hidden when searching)
              if (!isSearching) ...[
                const Text('Featured',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 320,
                  child: featuredEvents.isEmpty
                      ? const Center(child: Text('No upcoming events'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: featuredEvents.length,
                          itemBuilder: (context, index) {
                            final event = featuredEvents[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventDetailsPage(
                                      event: {
                                        'id': event.id,
                                        'name': event.title,
                                        'category': event.category,
                                        'date': event.dateTime.split('.')[0],
                                        'time': event.dateTime.split('.')[1],
                                        'location': event.location,
                                        'imageUrl': event.imageUrl,
                                        // 'description': event.description,
                                        'organizerName': event.organizer,
                                        'organizerImage': event.organizerImage,
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 260,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 5)
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
                                          child: const Icon(Icons.broken_image,
                                              color: Colors.grey),
                                        ),
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
                                                  color: Color.fromARGB(
                                                      255, 156, 39, 176))),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 14,
                                                  color: Color.fromARGB(
                                                      255, 156, 39, 176)),
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
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
              ],

              // Popular Events Header (hidden when searching)
              if (!isSearching) ...[
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
                          color: Color.fromARGB(255, 156, 39, 176),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Categories (hidden when searching)
                CategoryBar(
                  selectedCategory: selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Event Cards (shows search results when searching)
              eventsToDisplay.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          isSearching
                              ? 'No events found for "${_searchController.text}"'
                              : 'No events in this category',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: eventsToDisplay.length,
                      itemBuilder: (context, index) {
                        final event = eventsToDisplay[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailsPage(
                                  event: {
                                    'id': event.id,
                                    'name': event.title,
                                    'category': event.category,
                                    'date': event.dateTime.split('.')[0],
                                    'time': event.dateTime.split('.')[1],
                                    'location': event.location,
                                    'imageUrl': event.imageUrl,
                                    // 'description': event.description,
                                    'organizerName': event.organizer,
                                    'organizerImage': event.organizerImage,
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
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
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              title: Text(event.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.dateTime,
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 156, 39, 176))),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 14,
                                          color: Color.fromARGB(
                                              255, 156, 39, 176)),
                                      const SizedBox(width: 4),
                                      Text(event.location,
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
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
          selectedItemColor: const Color.fromARGB(255, 156, 39, 176),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onTap: (index) async {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PopularEventsPage()),
              );
            } else if (index == 2) {
              final prefs = await SharedPreferences.getInstance();
              final isGuest = prefs.getBool('isGuest') ?? true;

              if (!isGuest) {
                final userId = prefs.getInt('userId') ?? 0;
                print("Saved userId from prefs: $userId");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavouritesPage(userId: userId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please login to view favorites')),
                );
              }
            } else if (index == 3) {
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
