class Event {
  final int id;
  final String title;
  final String dateTime;
  final String location;
  final String organizer;
  final String category;
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.organizer,
    required this.category,
    required this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      dateTime: json['dateTime'],
      location: json['location'],
      organizer: json['organizer'],
      category: json['category'],
      imageUrl: json['imageUrl'],
    );
  }
}
