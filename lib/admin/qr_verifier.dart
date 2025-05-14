import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRVerifierPage extends StatefulWidget {
  @override
  _QRVerifierPageState createState() => _QRVerifierPageState();
}

class _QRVerifierPageState extends State<QRVerifierPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = 'Scan a QR code to verify ticket.';

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera(); // stop scanning after 1 result
      final qrCode = scanData.code;

      // Make HTTP call to verify QR code here
      final isValid = await _verifyQRCode(qrCode ?? '');

      setState(() {
        result =
            isValid ? '✅ Valid Ticket: $qrCode' : '❌ Invalid or Expired Ticket';
      });

      // resume scanning after short delay if needed
      await Future.delayed(Duration(seconds: 3));
      controller.resumeCamera();
    });
  }

  Future<bool> _verifyQRCode(String code) async {
    try {
      final url = Uri.parse('http://192.168.1.6:8081/api/qr/verify?code=$code');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      print('QR Verify Error: $e');
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
      appBar: AppBar(title: Text('QR Code Scanner')),
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
              child: Text(result, style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
