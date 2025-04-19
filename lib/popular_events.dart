import 'package:event_ease/event_detail_page.dart';
import 'package:flutter/material.dart';

class PopularEventsPage extends StatefulWidget {
  const PopularEventsPage({super.key});

  @override
  _PopularEventsPageState createState() => _PopularEventsPageState();
}

class _PopularEventsPageState extends State<PopularEventsPage> {
  String selectedCategory = "All";
  bool isSearching = false;
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> filteredEvents = [];

  final List<Map<String, String>> events = [
    {
      "image": "assets/images/festival.jpg",
      "name": "Art Workshop",
      "date": "Fri, Dec 20",
      "time": "11:00 - 15:00",
      "location": "New Avenue, NY",
      "category": "Workshops"
    },
    {
      "image": "assets/images/festival.jpg",
      "name": "Music Concert",
      "date": "Tue, Dec 19",
      "time": "19:00 - 22:00",
      "location": "Central Park, NY",
      "category": "Music"
    },
  ];

  void searchEvents(String query) {
    setState(() {
      isLoading = true;
      filteredEvents.clear();
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        filteredEvents = events
            .where((event) =>
                event["name"]!.toLowerCase().contains(query.toLowerCase()))
            .toList();
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  if (!isSearching)
                    Text(
                      'Popular Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.black87),
                    onPressed: () {
                      setState(() {
                        isSearching = !isSearching;
                        searchController.clear();
                        filteredEvents.clear();
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Search Box
              if (isSearching)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: searchController,
                    onChanged: searchEvents,
                    decoration: InputDecoration(
                      hintText: "Search for events...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFFF4F4F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16),

              // Events List
              Expanded(
                child: isSearching
                    ? Column(
                        children: [
                          if (isLoading)
                            Expanded(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (searchController.text.isNotEmpty &&
                              filteredEvents.isEmpty)
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/notfound.png",
                                        height: 220),
                                    SizedBox(height: 16),
                                    Text("Not Found",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Text("Sorry, no events match your search.",
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            )
                          else if (filteredEvents.isNotEmpty)
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredEvents.length,
                                itemBuilder: (context, index) {
                                  final event = filteredEvents[index];
                                  return ListTile(
                                    leading: Image.asset(event["image"]!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover),
                                    title: Text(event["name"]!),
                                    subtitle: Text(
                                        "${event["date"]} · ${event["time"]}"),
                                    trailing: Icon(Icons.arrow_forward_ios,
                                        size: 14, color: Colors.grey),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EventDetailsPage(event: event),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      )
                    : GridView.builder(
                        itemCount: events.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailsPage(event: event),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      spreadRadius: 1),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    child: Image.asset(event["image"]!,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(event["name"]!,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            "${event["date"]} · ${event["time"]}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6D62F4))),
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
            ],
          ),
        ),
      ),
    );
  }
}
