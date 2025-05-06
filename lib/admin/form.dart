import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class OrganizerEventForm extends StatefulWidget {
  @override
  _OrganizerEventFormState createState() => _OrganizerEventFormState();
}

class _OrganizerEventFormState extends State<OrganizerEventForm> {
  final _formKey = GlobalKey<FormState>();

  // Fields
  String title = "", location = "", about = "";
  String category = "Music";
  List<String> categories = [
    "Workshop",
    "Art",
    "Sports",
    "Festival",
    "Music",
    "Food",
    "Education"
  ];
  DateTime? eventDate;
  TimeOfDay? startTime;
  File? eventImage;
  List<File> galleryImages = [];

  int economySeats = 0, vipSeats = 0;
  double economyPrice = 0, vipPrice = 0, discount = 0;

  final picker = ImagePicker();

  Future pickEventImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => eventImage = File(picked.path));
    }
  }

  Future pickGalleryImages() async {
    final picked = await picker.pickMultiImage(imageQuality: 80);
    setState(() {
      galleryImages = picked.take(3).map((e) => File(e.path)).toList();
    });
  }

  Future pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
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

  String getFormattedDateTime() {
    if (eventDate == null || startTime == null) return 'Pick Date & Time';

    final startDateTime = DateTime(
      eventDate!.year,
      eventDate!.month,
      eventDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    final endDateTime = startDateTime.add(Duration(hours: 1));

    final dayFormat = DateFormat('E, MMM d'); // Tue, Feb 20
    final timeFormat = DateFormat.jm(); // 11:00 AM

    return "${dayFormat.format(startDateTime)} · ${timeFormat.format(startDateTime)} - ${timeFormat.format(endDateTime)}";
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate() && eventImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event submitted successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fill all fields and upload image.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromARGB(255, 156, 39, 176);

    return Scaffold(
      appBar: AppBar(
        // center the title
        centerTitle: true,
        backgroundColor: primaryColor,
        title: Text(
          "Add New Event",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Event Details",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor)),
              SizedBox(height: 16),

              // Event Title
              TextFormField(
                decoration: InputDecoration(labelText: "Event Title"),
                validator: (val) => val!.isEmpty ? "Enter title" : null,
                onChanged: (val) => title = val,
              ),
              SizedBox(height: 10),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(labelText: "Category"),
                onChanged: (val) => setState(() => category = val!),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
              ),
              SizedBox(height: 10),

              // Location
              TextFormField(
                decoration: InputDecoration(labelText: "Location"),
                validator: (val) => val!.isEmpty ? "Enter location" : null,
                onChanged: (val) => location = val,
              ),
              SizedBox(height: 16),

              // Date/Time Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getFormattedDateTime(),
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  ElevatedButton(
                    onPressed: pickDateTime,
                    child: Text(
                      "Pick Date & Time",
                      style:
                          TextStyle(color: Color.fromARGB(255, 156, 39, 176)),
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
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 40),
                        )
                      : Image.file(eventImage!, width: 100, height: 100),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: pickEventImage,
                    child: Text(
                      "Pick Cover Image",
                      style:
                          TextStyle(color: Color.fromARGB(255, 156, 39, 176)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // About
              TextFormField(
                decoration: InputDecoration(labelText: "About Event"),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? "Enter details" : null,
                onChanged: (val) => about = val,
              ),
              SizedBox(height: 16),

              // Gallery
              Text("Gallery Images (max 3)",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 5),
              Wrap(
                spacing: 8,
                children: galleryImages
                    .map((img) => Image.file(img,
                        width: 60, height: 60, fit: BoxFit.cover))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: pickGalleryImages,
                child: Text(
                  "Pick Gallery Images",
                  style: TextStyle(color: Color.fromARGB(255, 156, 39, 176)),
                ),
              ),
              SizedBox(height: 16),

              // Seats Row
              Row(children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Economy Seats"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => economySeats = int.tryParse(val) ?? 0,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "VIP Seats"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => vipSeats = int.tryParse(val) ?? 0,
                  ),
                ),
              ]),
              SizedBox(height: 10),

              // Prices Row
              Row(children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Economy Price"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        economyPrice = double.tryParse(val) ?? 0,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "VIP Price"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => vipPrice = double.tryParse(val) ?? 0,
                  ),
                ),
              ]),
              SizedBox(height: 10),

              // Discount
              TextFormField(
                decoration: InputDecoration(labelText: "Discount (%)"),
                keyboardType: TextInputType.number,
                onChanged: (val) => discount = double.tryParse(val) ?? 0,
              ),
              SizedBox(height: 25),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: handleSubmit,
                  child: Text(
                    "Submit Event",
                    style: TextStyle(color: Color.fromARGB(255, 156, 39, 176)),
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
