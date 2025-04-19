import 'package:event_ease/attendees_page.dart';
import 'package:event_ease/book_event_form_page.dart';
import 'package:event_ease/organizer_profile.dart';
import 'package:event_ease/share_sheet.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, String> event;

  const EventDetailsPage({super.key, required this.event});

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
                        "assets/images/festival.jpg",
                        "assets/images/notfound.png",
                        "assets/images/profile_image.jpg",
                      ].map((image) {
                        return ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16)),
                          child: Image.asset(image,
                              fit: BoxFit.cover, width: double.infinity),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Name & Category
                        Text(event['name']!,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(label: Text(event['category']!)),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AttendeesPage()),
                                );
                              },
                              child: Row(
                                children: [
                                  Text("20,000+ Going",
                                      style: TextStyle(color: Colors.grey)),
                                  Icon(Icons.arrow_forward, color: Colors.grey),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Date & Time
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event['date']!,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(event['time']!),
                              ],
                            ),
                            Spacer(),
                            ElevatedButton(
                                onPressed: () {},
                                child: Text("Add to Calendar"))
                          ],
                        ),
                        SizedBox(height: 16),
                        // Location
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(child: Text(event['location']!)),
                            TextButton(
                                onPressed: () {}, child: Text("Get Directions"))
                          ],
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        // Organizer Profile - Placed Below Location

                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/organizer.jpg"),
                          ),
                          title: Text("World of Music"),
                          subtitle: Text("Organizer"),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OrganizerProfilePage()),
                              );
                            },
                            child: Text("Follow"),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrganizerProfilePage()),
                            );
                          },
                        ),

                        Divider(),
                        // About Event
                        Text("About Event",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt..."),
                        TextButton(onPressed: () {}, child: Text("Read more")),
                        SizedBox(height: 16),
                        // Gallery
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Gallery (Pre-Event)",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            TextButton(
                                onPressed: () {}, child: Text("See All")),
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
                                .map((image) => Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(image,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Location Map Placeholder
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(Icons.map,
                                size: 50, color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.black),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.black),
                  onPressed: () {
                    showShareBottomSheet(context); // Call the function
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to Book Event Page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BookEventPage(), // Navigate to booking page
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            backgroundColor: Colors.blueAccent, // Button color
          ),
          child: Text("Book Event", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
