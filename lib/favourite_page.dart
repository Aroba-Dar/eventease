import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Page to display the user's favorite events
class FavouritesPage extends StatefulWidget {
  final int userId; // User ID to fetch favorite events

  FavouritesPage({required this.userId});

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<dynamic> favouriteEvents = []; // List to store favorite events

  @override
  void initState() {
    super.initState();
    fetchFavourites(); // Fetch favorite events when the page initializes
  }

  // Fetch favorite events from the server
  Future<void> fetchFavourites() async {
    final response = await http.get(
      Uri.parse(
          "http://192.168.1.6:8081/favorites/${widget.userId}"), // API endpoint
    );

    // Debugging logs for response
    print("Response: ${response.body}");
    print("Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      // If the response is successful, update the favorite events list
      setState(() {
        favouriteEvents = json.decode(response.body);
      });
    } else {
      // Log errors if the response fails
      print("Error: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Favourite Events"), // AppBar title
      ),
      body: favouriteEvents.isEmpty
          ? Center(
              child: const Text(
                  "No favourites found."), // Message if no favorites are found
            )
          : ListView.builder(
              itemCount: favouriteEvents.length, // Number of favorite events
              itemBuilder: (context, index) {
                var event = favouriteEvents[index]; // Current event data
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 15), // Card margin
                  elevation: 5, // Card shadow
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          8), // Rounded corners for the image
                      child: Image.network(
                        event['imageUrl'] ?? '', // Event image URL
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover, // Fit image within the container
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors
                              .grey.shade300, // Placeholder background color
                          child: const Icon(Icons.broken_image,
                              color: Colors
                                  .grey), // Placeholder icon for broken images
                        ),
                      ),
                    ),
                    title: Text(
                      event['title'] ?? "No title", // Event title
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event date and time
                        Text(
                          event['dateTime'] ??
                              "Date not available", // Handle null dateTime
                          style: const TextStyle(
                            color: Color.fromARGB(
                                255, 156, 39, 176), // Purple color
                          ),
                        ),
                        const SizedBox(
                            height: 4), // Space between date and location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on, // Location icon
                              size: 14,
                              color: Color.fromARGB(
                                  255, 156, 39, 176), // Purple color
                            ),
                            const SizedBox(
                                width: 4), // Space between icon and text
                            Text(
                              event['location'] ??
                                  "Location not available", // Handle null location
                              style: const TextStyle(
                                  color: Colors.grey), // Grey text color
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
