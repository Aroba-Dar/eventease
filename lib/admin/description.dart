import 'dart:convert';
import 'package:event_ease/admin/galleryImage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DescriptionEvent extends StatefulWidget {
  final int eventId;

  const DescriptionEvent({Key? key, required this.eventId}) : super(key: key);

  @override
  _DescriptionEventState createState() => _DescriptionEventState();
}

class _DescriptionEventState extends State<DescriptionEvent> {
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  bool isDescriptionSubmitted = false; // Track if description is submitted

  Future<void> submitDescription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final response = await http.post(
      Uri.parse(
          'http://192.168.1.6:8081/api/about-event/events'), // Your backend endpoint
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "eventId": widget.eventId,
        "content": _descriptionController.text.trim(),
      }),
    );

    setState(() => isSubmitting = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("About event content added successfully.")),
      );
      setState(
          () => isDescriptionSubmitted = true); // Mark description as submitted
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit content")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Description", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 156, 39, 176),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Enter Event Description",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 156, 39, 176),
                                  width: 2),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Please enter a description'
                                  : null,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: isSubmitting
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Icon(Icons.save, color: Colors.white, size: 18),
                          label: Text(
                              isSubmitting
                                  ? "Submitting..."
                                  : "Save Description",
                              style: TextStyle(color: Colors.white)),
                          onPressed: isSubmitting ? null : submitDescription,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 156, 39, 176),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Show the arrow button and Go to Upload Gallery Images button after description is submitted
              if (isDescriptionSubmitted)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Color.fromARGB(255, 156, 39, 176),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadGalleryImagesPage(
                                  eventId: widget.eventId),
                            ),
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadGalleryImagesPage(
                                  eventId: widget.eventId),
                            ),
                          );
                        },
                        child: Text(
                          "Go to Upload Gallery Images",
                          style: TextStyle(
                              color: Color.fromARGB(255, 156, 39, 176)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
