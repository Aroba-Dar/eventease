class Event {
  final int id;
  final String title;
  final String dateTime;
  final String location;
  final String category;
  final String imageUrl;
  final String organizer;
  final String organizerImage;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.organizer,
    required this.organizerImage,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      dateTime: json['dateTime'],
      location: json['location'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      organizer: json['organizer'],
      organizerImage: json['organizerImage'],
    );
  }
}
