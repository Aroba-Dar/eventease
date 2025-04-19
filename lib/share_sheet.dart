import 'package:flutter/material.dart';

void showShareBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Share",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildShareIcon(Icons.message, "WhatsApp"),
                _buildShareIcon(Icons.facebook, "Facebook"),
                _buildShareIcon(Icons.share, "Twitter"),
                _buildShareIcon(Icons.camera_alt, "Instagram"),
                _buildShareIcon(Icons.email, "Yahoo"),
                _buildShareIcon(Icons.video_collection, "TikTok"),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      );
    },
  );
}

Widget _buildShareIcon(IconData icon, String label) {
  return Column(
    children: [
      CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        child: Icon(icon, size: 30, color: Colors.black87),
      ),
      SizedBox(height: 8),
      Text(label, style: TextStyle(fontSize: 12)),
    ],
  );
}
