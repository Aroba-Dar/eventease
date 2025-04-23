class Event {
  final int event_id;
  final String title;
  final String dateTime;
  final String location;
  final String organizer;
  final String category;
  final String imageUrl;
  final String organizerName; // Add organizer name
  final String profileImage; // Add organizer image URL

  Event({
    required this.event_id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.organizer,
    required this.category,
    required this.imageUrl,
    required this.organizerName, // Add organizer name to constructor
    required this.profileImage, // Add organizer image to constructor
  });

  // Modify fromJson to read these new properties from the backend
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      event_id: json['id'],
      title: json['title'],
      dateTime: json['dateTime'],
      location: json['location'],
      organizer: json['organizer'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      organizerName: json['organizerName'] ??
          'Unknown Organizer', // Default to 'Unknown' if missing
      profileImage:
          json['profileImage'] ?? '', // Default to empty string if missing
    );
  }
}
