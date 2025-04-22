import 'package:event_ease/attendees_page.dart';
import 'package:event_ease/book_event_form_page.dart';
import 'package:event_ease/organizer_profile.dart';
import 'package:event_ease/seat_count_page.dart';
import 'package:event_ease/share_sheet.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({super.key, required this.event});

  Future<void> _handleBooking(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? true;

    if (isGuest) {
      // 1) Show the guest booking form
      final formSuccess = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => BookEventPage(event: event),
        ),
      );
      // 2) If the form was submitted successfully, go to seat page
      if (formSuccess == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookEventSeatPage(event: event),
          ),
        );
      }
    } else {
      // Registered user → go straight to seat page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookEventSeatPage(event: event),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 300.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: CarouselSlider(
                      options: CarouselOptions(height: 300, autoPlay: true),
                      items: [
                        event['imageUrl'] ?? '',
                      ].map((imageUrl) {
                        return imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              )
                            : Image.asset(
                                "assets/images/notfound.png",
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                      }).toList(),
                    ),
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(label: Text(event['category'] ?? '')),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AttendeesPage()),
                            );
                          },
                          child: const Row(
                            children: [
                              Text("20,000+ Going",
                                  style: TextStyle(color: Colors.grey)),
                              Icon(Icons.arrow_forward, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['date'] ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(event['time'] ?? ''),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                            onPressed: () {},
                            child: const Text("Add to Calendar")),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(event['location'] ?? '')),
                        TextButton(
                            onPressed: () {},
                            child: const Text("Get Directions")),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundImage:
                            AssetImage("assets/images/organizer.jpg"),
                      ),
                      title: const Text("World of Music"),
                      subtitle: const Text("Organizer"),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => OrganizerProfilePage()),
                          );
                        },
                        child: const Text("Follow"),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => OrganizerProfilePage()),
                        );
                      },
                    ),
                    const Divider(),
                    const Text(
                      "About Event",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(event['description'] ?? 'No description available.'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Gallery (Pre-Event)",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                            onPressed: () {}, child: const Text("See All")),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          "assets/images/event1.jpg",
                          "assets/images/event2.jpg",
                          "assets/images/event3.jpg",
                        ]
                            .map((img) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
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
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child:
                            Icon(Icons.map, size: 50, color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.black),
                  onPressed: () {
                    showShareBottomSheet(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () => _handleBooking(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.blueAccent,
          ),
          child: const Text("Book Event", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
