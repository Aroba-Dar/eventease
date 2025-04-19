import 'package:flutter/material.dart';

class OrganizerProfilePage extends StatelessWidget {
  const OrganizerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text("Organizer", style: TextStyle(color: Colors.black)),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Profile Section
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/images/organizer.jpg"),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "World of Music",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard("Events", "24"),
                      _buildStatCard("Followers", "967K"),
                      _buildStatCard("Following", "20"),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text("Follow"),
                      ),
                      SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(color: Colors.blueAccent),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.message, color: Colors.blueAccent),
                            SizedBox(width: 4),
                            Text("Message",
                                style: TextStyle(color: Colors.blueAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tab Menu
            TabBar(
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              tabs: [
                Tab(text: "Events"),
                Tab(text: "Collections"),
                Tab(text: "About"),
              ],
            ),
            // Expanded TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  _buildEventList(),
                  _buildCollections(),
                  _buildAbout(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stats Card Widget
  Widget _buildStatCard(String title, String count) {
    return Expanded(
      child: Column(
        children: [
          Text(count,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Events List (FIXED)
  Widget _buildEventList() {
    List<Map<String, String>> events = [
      {
        "image": "assets/images/festival.jpg",
        "name": "Music & Concert Fest",
        "date": "Sun, Dec 23 - 19:00 - 23:00 PM",
        "location": "Grand Park, New York",
      },
      {
        "image": "assets/images/profile_image.jpg",
        "name": "DJ Music Competition",
        "date": "Tue, Dec 16 - 18:00 PM",
        "location": "New Avenue, Washington",
      },
      {
        "image": "assets/images/notfound.png",
        "name": "Electronic Dance Party",
        "date": "Sat, Dec 30 - 20:00 PM",
        "location": "Sunset Beach, Miami",
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        var event = events[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(event["image"]!,
                  width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text(event["name"]!,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event["date"]!, style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blueAccent, size: 16),
                    SizedBox(width: 4),
                    Expanded(
                        child: Text(event["location"]!,
                            style: TextStyle(color: Colors.grey))),
                  ],
                ),
              ],
            ),
            trailing: Icon(Icons.favorite_border, color: Colors.red),
          ),
        );
      },
    );
  }

  // Collections Placeholder
  Widget _buildCollections() {
    return Center(
      child: Text("No Collections Yet", style: TextStyle(color: Colors.grey)),
    );
  }

  // About Section
  Widget _buildAbout() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        "World of Music is an international event organizer that hosts concerts and festivals worldwide, bringing artists and audiences together.",
        textAlign: TextAlign.center,
      ),
    );
  }
}
