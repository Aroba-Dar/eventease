import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRVerifierPage extends StatefulWidget {
  const QRVerifierPage({super.key});

  @override
  _QRVerifierPageState createState() => _QRVerifierPageState();
}

class _QRVerifierPageState extends State<QRVerifierPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = 'Scan a QR code to verify ticket';

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  // Request camera permission for QR scanning
  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() {
        result = 'Camera permission is required!';
      });
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  // Called when QR view is created and starts listening for scan results
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();

      // Remove invisible characters from scanned QR code
      String? qrCodeRaw = scanData.code
          ?.trim()
          .replaceAll(RegExp(r'[\n\r\t\u200B-\u200D\uFEFF]'), '');
      print('Raw scanned QR code: "$qrCodeRaw"');

      if (qrCodeRaw == null || qrCodeRaw.isEmpty) {
        setState(() {
          result = 'Invalid QR Code';
        });
        controller.resumeCamera();
        return;
      }

      String bookingId = '';
      int eventId = 1;

      try {
        // Try to parse QR code as JSON
        final data = jsonDecode(qrCodeRaw);
        bookingId = data['bookingId'] ?? '';
        final eventIdRaw = data['eventId']?.toString() ?? '';
        eventId = int.tryParse(eventIdRaw) ?? 1;
        print('Parsed JSON -> bookingId: $bookingId, eventId: $eventId');
      } catch (e) {
        // If not JSON, treat the whole QR as bookingId
        print('JSON decode error: $e');
        bookingId = qrCodeRaw;
        print('Not JSON, using entire QR as bookingId');
      }

      if (bookingId.isEmpty) {
        setState(() {
          result = 'Invalid QR Code data';
        });
        controller.resumeCamera();
        return;
      }

      // Verify the QR code with backend
      final isValid = await _verifyQRCode(bookingId, eventId);

      setState(() {
        result = isValid
            ? 'Valid Ticket\nBooking ID: $bookingId\nEvent ID: $eventId'
            : 'Invalid or Expired Ticket';
      });

      await Future.delayed(Duration(seconds: 3));
      controller.resumeCamera();
    });
  }

  // Calls backend API to verify the ticket using bookingId and eventId
  Future<bool> _verifyQRCode(String bookingId, int eventId) async {
    try {
      final queryParams = {
        'bookingId': bookingId,
        'eventId': eventId.toString(),
      };

      final uri = Uri(
        scheme: 'http',
        host: '192.168.145.196',
        port: 8081,
        path: '/api/tickets/verify',
        queryParameters: queryParams,
      );

      print('Verify URL: $uri');

      final response = await http.get(uri);

      print('Response Code: ${response.statusCode}');
      print('Raw Response Body: ${response.body}');
      print('Parsed bookingId: "$bookingId", eventId: $eventId');

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final status = jsonResponse['status']?.toString().toUpperCase() ?? '';
      final message = jsonResponse['message'] ?? '';

      print('Status: $status');
      print('Message: $message');

      return status == 'VALID';
    } catch (e) {
      print('Error verifying ticket: $e');
      return false;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 156, 39, 176),
        title: Text(
          'QR Code Scanner',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 10,
                borderLength: 20,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                result,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
