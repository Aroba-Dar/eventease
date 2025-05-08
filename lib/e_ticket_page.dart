import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/services.dart';

class ETicketPage extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String userName;
  final String userContact;
  final String bookingId;

  const ETicketPage({
    super.key,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.userName,
    required this.userContact,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("E-Ticket"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            QrImageView(
              data: bookingId,
              version: QrVersions.auto,
              size: 200,
            ),
            SizedBox(height: 20),

            // Event Details
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow("Event", eventName),
                    _buildDetailRow("Date", eventDate),
                    _buildDetailRow("Venue", eventLocation),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),

            // User Details
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow("Name", userName),
                    _buildDetailRow("Contact", userContact),
                    _buildDetailRow("Booking ID", bookingId),
                  ],
                ),
              ),
            ),
            Spacer(),

            ElevatedButton(
              onPressed: () => _downloadTicket(context),
              child: Text("Download Ticket",
                  style: TextStyle(color: Color.fromARGB(255, 156, 39, 176))),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _downloadTicket(BuildContext context) async {
    final status = await Permission.storage.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    final pdf = pw.Document();

    try {
      // Generate QR code image
      final qrValidationResult = QrValidator.validate(
        data: bookingId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.Q,
      );

      if (qrValidationResult.status != QrValidationStatus.valid) {
        throw Exception('Invalid QR Code data');
      }

      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );

      final imageData = await painter.toImageData(200);
      final qrImage = pw.MemoryImage(imageData!.buffer.asUint8List());

      // Add content to PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('E-Ticket', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Image(qrImage, width: 150, height: 150),
              pw.SizedBox(height: 16),
              pw.Text('Event: $eventName'),
              pw.Text('Date: $eventDate'),
              pw.Text('Location: $eventLocation'),
              pw.SizedBox(height: 12),
              pw.Text('Name: $userName'),
              pw.Text('Contact: $userContact'),
              // pw.Text('Booking ID: $bookingId'),
            ],
          ),
        ),
      );

      // Save to Downloads
      final downloadDir = Directory('/storage/emulated/0/Download');
      final file = File('${downloadDir.path}/ticket_$bookingId.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket downloaded to Downloads folder.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download ticket: $e')),
      );
    }
  }
}
