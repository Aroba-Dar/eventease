import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavouritesPage extends StatefulWidget {
  final int userId;

  FavouritesPage({required this.userId});

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<dynamic> favouriteEvents = [];

  @override
  void initState() {
    super.initState();
    fetchFavourites();
  }

  Future<void> fetchFavourites() async {
    final response = await http.get(
      Uri.parse("http://192.168.1.6:8081/favorites/${widget.userId}"),
    );
    print("Response: ${response.body}");
    print("Status Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      setState(() {
        favouriteEvents = json.decode(response.body);
      });
    } else {
      print("Error: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Favourite Events")),
      body: favouriteEvents.isEmpty
          ? Center(child: Text("No favourites found."))
          : ListView.builder(
              itemCount: favouriteEvents.length,
              itemBuilder: (context, index) {
                var event = favouriteEvents[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  elevation: 5,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        event['imageUrl'] ??
                            '', // Use a default value if imageUrl is null
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(
                      event['title'] ?? "No title", // Handle null title
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['dateTime'] ??
                              "Date not available", // Handle null dateTime
                          style: const TextStyle(
                            color: Color.fromARGB(255, 156, 39, 176),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Color.fromARGB(255, 156, 39, 176),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event['location'] ??
                                  "Location not available", // Handle null location
                              style: const TextStyle(color: Colors.grey),
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
