import 'dart:io';
import 'dart:convert';
import 'package:event_ease/admin/seatPricing.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadGalleryImagesPage extends StatefulWidget {
  final int eventId;
  final int organizerId;
  const UploadGalleryImagesPage({
    Key? key,
    required this.eventId,
    required this.organizerId,
  }) : super(key: key);

  @override
  State<UploadGalleryImagesPage> createState() =>
      _UploadGalleryImagesPageState();
}

class _UploadGalleryImagesPageState extends State<UploadGalleryImagesPage> {
  List<XFile> _images = [];
  bool isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    final List<XFile>? picked = await _picker.pickMultiImage();
    if (picked != null && picked.length <= 3) {
      setState(() => _images = picked);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select up to 3 images only.")),
      );
    }
  }

  Future<void> uploadImages() async {
    if (_images.isEmpty) return;

    setState(() => isUploading = true);

    try {
      for (var image in _images) {
        // Read the file as bytes
        final bytes = await File(image.path).readAsBytes();
        // Convert bytes to base64 string
        final base64Image = base64Encode(bytes);

        // Send base64 image to backend
        final response = await http.post(
          Uri.parse(
              'http://192.168.1.6:8081/api/gallery/upload/${widget.eventId}'),
          headers: {"Content-Type": "text/plain"},
          body: base64Image,
        );

        if (response.statusCode != 200) {
          throw Exception('Upload failed for ${image.name}');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Images uploaded successfully.")),
      );
      setState(() => _images.clear());
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload images.")),
      );
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Upload Gallery Images",
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 156, 39, 176),
        // Back button to navigate to the previous screen
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: pickImages,
              icon: Icon(Icons.photo_library, color: Colors.white),
              label: Text("Pick up to 3 Images",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 156, 39, 176),
              ),
            ),
            SizedBox(height: 20),
            // Row with 3 fixed image card spaces
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _imageCard(0),
                SizedBox(width: 10),
                _imageCard(1),
                SizedBox(width: 10),
                _imageCard(2),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isUploading ? null : uploadImages,
              icon: isUploading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.upload_file, color: Colors.white),
              label: Text(isUploading ? "Uploading..." : "Upload Images",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 156, 39, 176),
              ),
            ),
            SizedBox(height: 20),
            // TextButton to navigate to the Seat Pricing Page
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeatPricingPage(
                        eventId: widget.eventId,
                        organizerId: widget.organizerId // Passing eventId
                        ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_forward,
                    color: Color.fromARGB(255, 156, 39, 176),
                  ),
                  Text(
                    " Enter Seat Pricing and Availability",
                    style: TextStyle(
                        color: Color.fromARGB(255, 156, 39, 176), fontSize: 16),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Image card that will display image or placeholder
  Widget _imageCard(int index) {
    if (index < _images.length) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: FileImage(File(_images[index].path)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: IconButton(
          icon: Icon(Icons.add_a_photo,
              color: const Color.fromARGB(255, 117, 115, 115)),
          onPressed: () {},
        ),
      );
    }
  }
}
