import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Form to allow organizers to add a new event
class OrganizerEventForm extends StatefulWidget {
  @override
  _OrganizerEventFormState createState() => _OrganizerEventFormState();
}

class _OrganizerEventFormState extends State<OrganizerEventForm> {
  final _formKey = GlobalKey<FormState>(); // Key for the form

  // Fields for event details
  String title = "", location = "", about = "";
  String category = "Music"; // Default category
  List<String> categories = [
    "Workshop",
    "Art",
    "Sports",
    "Festival",
    "Music",
    "Food",
    "Education"
  ]; // List of categories
  DateTime? eventDate; // Selected event date
  TimeOfDay? startTime; // Selected start time
  File? eventImage; // Cover image for the event
  List<File> galleryImages = []; // Gallery images for the event

  // Fields for seat and pricing details
  int economySeats = 0, vipSeats = 0;
  double economyPrice = 0, vipPrice = 0, discount = 0;

  final picker = ImagePicker(); // Image picker instance

  // Method to pick a cover image for the event
  Future pickEventImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => eventImage = File(picked.path));
    }
  }

  // Method to pick multiple gallery images for the event
  Future pickGalleryImages() async {
    final picked = await picker.pickMultiImage(imageQuality: 80);
    setState(() {
      galleryImages =
          picked.take(3).map((e) => File(e.path)).toList(); // Limit to 3 images
    });
  }

  // Method to pick the event date and time
  Future pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(), // Prevent selecting past dates
      lastDate: DateTime(2100), // Allow future dates
      initialDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          eventDate = pickedDate;
          startTime = pickedTime;
        });
      }
    }
  }

  // Method to format the selected date and time for display
  String getFormattedDateTime() {
    if (eventDate == null || startTime == null) return 'Pick Date & Time';

    final startDateTime = DateTime(
      eventDate!.year,
      eventDate!.month,
      eventDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    final endDateTime =
        startDateTime.add(Duration(hours: 1)); // Default event duration: 1 hour

    final dayFormat = DateFormat('E, MMM d'); // Format: Tue, Feb 20
    final timeFormat = DateFormat.jm(); // Format: 11:00 AM

    return "${dayFormat.format(startDateTime)} · ${timeFormat.format(startDateTime)} - ${timeFormat.format(endDateTime)}";
  }

  // Method to handle form submission
  void handleSubmit() {
    if (_formKey.currentState!.validate() && eventImage != null) {
      // Show success message if form is valid and image is uploaded
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event submitted successfully!")),
      );
    } else {
      // Show error message if form is incomplete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fill all fields and upload image.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Color.fromARGB(255, 156, 39, 176); // Primary color for the form

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center the title
        backgroundColor: primaryColor,
        title: Text(
          "Add New Event",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16), // Padding for the form
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              Text("Event Details",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor)),
              SizedBox(height: 16),

              // Event Title
              TextFormField(
                decoration: InputDecoration(labelText: "Event Title"),
                validator: (val) =>
                    val!.isEmpty ? "Enter title" : null, // Validation
                onChanged: (val) => title = val, // Update title
              ),
              SizedBox(height: 10),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(labelText: "Category"),
                onChanged: (val) =>
                    setState(() => category = val!), // Update category
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
              ),
              SizedBox(height: 10),

              // Location
              TextFormField(
                decoration: InputDecoration(labelText: "Location"),
                validator: (val) =>
                    val!.isEmpty ? "Enter location" : null, // Validation
                onChanged: (val) => location = val, // Update location
              ),
              SizedBox(height: 16),

              // Date/Time Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getFormattedDateTime(),
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  ElevatedButton(
                    onPressed: pickDateTime, // Open date/time picker
                    child: Text(
                      "Pick Date & Time",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Cover Image
              Text("Cover Image",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  eventImage == null
                      ? Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300], // Placeholder background
                          child:
                              Icon(Icons.image, size: 40), // Placeholder icon
                        )
                      : Image.file(eventImage!,
                          width: 100, height: 100), // Display selected image
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: pickEventImage, // Open image picker
                    child: Text(
                      "Pick Cover Image",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // About
              TextFormField(
                decoration: InputDecoration(labelText: "About Event"),
                maxLines: 3, // Multi-line input
                validator: (val) =>
                    val!.isEmpty ? "Enter details" : null, // Validation
                onChanged: (val) => about = val, // Update about
              ),
              SizedBox(height: 16),

              // Gallery
              Text("Gallery Images (max 3)",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 5),
              Wrap(
                spacing: 8, // Space between images
                children: galleryImages
                    .map((img) => Image.file(img,
                        width: 60, height: 60, fit: BoxFit.cover))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: pickGalleryImages, // Open gallery picker
                child: Text(
                  "Pick Gallery Images",
                  style: TextStyle(color: primaryColor),
                ),
              ),
              SizedBox(height: 16),

              // Seats Row
              Row(children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Economy Seats"),
                    keyboardType: TextInputType.number, // Numeric input
                    onChanged: (val) => economySeats =
                        int.tryParse(val) ?? 0, // Update economy seats
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "VIP Seats"),
                    keyboardType: TextInputType.number, // Numeric input
                    onChanged: (val) =>
                        vipSeats = int.tryParse(val) ?? 0, // Update VIP seats
                  ),
                ),
              ]),
              SizedBox(height: 10),

              // Prices Row
              Row(children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Economy Price"),
                    keyboardType: TextInputType.number, // Numeric input
                    onChanged: (val) => economyPrice =
                        double.tryParse(val) ?? 0, // Update economy price
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "VIP Price"),
                    keyboardType: TextInputType.number, // Numeric input
                    onChanged: (val) => vipPrice =
                        double.tryParse(val) ?? 0, // Update VIP price
                  ),
                ),
              ]),
              SizedBox(height: 10),

              // Discount
              TextFormField(
                decoration: InputDecoration(labelText: "Discount (%)"),
                keyboardType: TextInputType.number, // Numeric input
                onChanged: (val) =>
                    discount = double.tryParse(val) ?? 0, // Update discount
              ),
              SizedBox(height: 25),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: handleSubmit, // Submit the form
                  child: Text(
                    "Submit Event",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
