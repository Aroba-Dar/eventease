import 'dart:io';
import 'dart:convert';
import 'package:event_ease/admin/description.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class OrganizerEventForm extends StatefulWidget {
  @override
  _OrganizerEventFormState createState() => _OrganizerEventFormState();
}

class _OrganizerEventFormState extends State<OrganizerEventForm> {
  final _formKey = GlobalKey<FormState>();

  String title = "", location = "", about = "", category = "Music";
  DateTime? eventDate;
  TimeOfDay? startTime;
  File? eventImage;
  int organizerId = 4; // Replace with actual organizer ID
  int? eventId; // <-- Added this for accessing eventId later

  final picker = ImagePicker();

  Future pickEventImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => eventImage = File(picked.path));
    }
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
    final dayFormat = DateFormat('E, MMM d');
    final timeOnlyFormat = DateFormat('HH:mm');
    final timeWithAmPmFormat = DateFormat('hh:mm a');

    return "${dayFormat.format(startDateTime)} . "
        "${timeOnlyFormat.format(startDateTime)} - "
        "${timeWithAmPmFormat.format(endDateTime)}";
  }

  Future<void> handleSubmit() async {
    if (_formKey.currentState!.validate() &&
        eventImage != null &&
        eventDate != null &&
        startTime != null) {
      String formattedDateTime = getFormattedDateTime();
      final bytes = await eventImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final eventData = {
        "title": title,
        "category": category,
        "dateTime": formattedDateTime,
        "location": location,
        "imageUrl": base64Image,
        "organizer": {
          "organizerId": organizerId,
        }
      };

      final response = await http.post(
        Uri.parse('http://192.168.1.6:8081/events/add_events'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(eventData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        setState(() {
          eventId = responseData['eventId']; // <-- Save eventId
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Event submitted successfully! Event ID: $eventId")),
        );
      } else {
        print("Error Status: ${response.statusCode}");
        print("Error Body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Error: ${response.statusCode} ${response.reasonPhrase}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Event",
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 156, 39, 176),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 23),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title of Event',
                  // filled: true,
                  // fillColor: Color.fromARGB(255, 250, 226, 246),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 156, 39, 176), width: 2),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
                onChanged: (value) => setState(() => title = value),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Location',
                  // filled: true,
                  // fillColor: Color.fromARGB(255, 255, 243, 250),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 156, 39, 176), width: 2),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Enter location' : null,
                onChanged: (value) => setState(() => location = value),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                icon: Icon(Icons.arrow_drop_down,
                    color: Color.fromARGB(255, 156, 39, 176)),
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  // filled: true,
                  // fillColor: Color.fromARGB(255, 255, 243, 250),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 156, 39, 176), width: 2),
                  ),
                ),
                items: [
                  'Workshop',
                  'Art',
                  'Sports',
                  'Festival',
                  'Music',
                  'Food',
                  'Education'
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text(getFormattedDateTime()),
                trailing: Icon(Icons.calendar_today,
                    color: Color.fromARGB(255, 156, 39, 176)),
                onTap: pickDateTime,
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: pickEventImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 241, 206, 236),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: eventImage != null
                        ? Image.file(eventImage!, fit: BoxFit.cover)
                        : Center(child: Text("Tap to select event image")),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 156, 39, 176),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  onPressed: handleSubmit,
                  child: Text("Submit Event",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: eventId != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DescriptionEvent(eventId: eventId!),
                            ),
                          );
                        }
                      : null,
                  icon: Icon(Icons.arrow_forward,
                      color: Color.fromARGB(255, 156, 39, 176)),
                  label: Text(
                    "Go to Add Description",
                    style: TextStyle(
                      color: Color.fromARGB(255, 156, 39, 176),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
