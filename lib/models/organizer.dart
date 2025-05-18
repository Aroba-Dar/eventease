// Model class representing an event organizer with all relevant details.
class Organizer {
  final int organizerId;
  final String organizerName;
  final String profileImage;
  final String email;
  final String gender;
  final String contactNumber;
  final String dob;
  final String password;
  final String country;

  Organizer({
    required this.organizerId,
    required this.organizerName,
    required this.profileImage,
    required this.email,
    required this.gender,
    required this.contactNumber,
    required this.dob,
    required this.password,
    required this.country,
  });

  // Creates an Organizer instance from a JSON map.
  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      profileImage: json['profileImage'],
      email: json['email'],
      gender: json['gender'],
      contactNumber: json['contactNumber'],
      dob: json['dob'],
      password: json['password'],
      country: json['country'],
    );
  }
}
