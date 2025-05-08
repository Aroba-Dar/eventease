import 'package:event_ease/payment_result_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EnterPinPage extends StatefulWidget {
  final Map<String, dynamic> event;
  final int seatCount;
  final double totalAmount;
  final String userName;
  final String userEmail;
  final String userPhone;

  const EnterPinPage({
    super.key,
    required this.event,
    required this.seatCount,
    required this.totalAmount,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  _EnterPinPageState createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  List<String> otp = ['', '', '', '', '', ''];
  int currentOtpIndex = 0;
  bool _isLoading = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _notificationEntry;
  String? _lastGeneratedOtp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      _generateOtp();
    });
    _controller.addListener(_updateOtp);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeNotification();
    super.dispose();
  }

  void _removeNotification() {
    _notificationEntry?.remove();
    _notificationEntry = null;
  }

  void _updateOtp() {
    final text = _controller.text;
    if (text.length > 6) {
      _controller.text = text.substring(0, 6);
      _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    }
    setState(() {
      for (int i = 0; i < 6; i++) {
        otp[i] = i < text.length ? text[i] : '';
      }
      currentOtpIndex = text.length;
    });
  }

  void _showOtpNotification(String otpCode) {
    _removeNotification();
    _lastGeneratedOtp = otpCode;

    final overlay = Overlay.of(context);
    _notificationEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Your OTP Code',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        otpCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _removeNotification,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_notificationEntry!);
    Future.delayed(const Duration(seconds: 10), _removeNotification);
  }

  Future<void> _generateOtp() async {
    setState(() {
      _isLoading = true;
      _controller.clear();
      _updateOtp(); // Clear the OTP fields
    });

    try {
      debugPrint('Generating OTP for ${widget.userEmail}');
      final response = await http.post(
        Uri.parse(
            'http://192.168.1.6:8081/api/otp/generate?email=${widget.userEmail}'),
      );

      debugPrint(
          'OTP Generation Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final otpCode = responseData['debugOtp'] ?? '123456';
        _showOtpNotification(otpCode);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate OTP: ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint('OTP Generation Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final enteredOtp = otp.join();
    if (enteredOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter complete 6-digit OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      debugPrint('Verifying OTP: $enteredOtp for ${widget.userEmail}');

      // For testing purposes, you can bypass the API call with this:
      if (_lastGeneratedOtp != null && enteredOtp == _lastGeneratedOtp) {
        debugPrint('OTP verification successful (local check)');
        await _completeBooking();
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.6:8081/api/otp/verify'),
        body: jsonEncode({
          'email': widget.userEmail,
          'otpCode': enteredOtp,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint(
          'OTP Verification Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final isValid = responseData['isValid'] ?? false;

        if (isValid) {
          await _completeBooking();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid OTP. Please try again.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP verification failed: ${response.body}")),
        );
      }
    } catch (e) {
      debugPrint('OTP Verification Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _completeBooking() async {
    try {
      debugPrint('Starting booking process...');

      final bookingData = {
        'eventId': widget.event['id'],
        'userEmail': widget.userEmail,
        'userName': widget.userName,
        'userPhone': widget.userPhone,
        'seatCount': widget.seatCount,
        'totalAmount': widget.totalAmount,
        'bookingTime': DateTime.now().toIso8601String(),
      };

      debugPrint('Booking data: $bookingData');

      // For testing purposes, you can bypass the API call with this:
      final bookingId = "BK-${DateTime.now().millisecondsSinceEpoch}";
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentResultPopup(
            eventName: widget.event['name'],
            eventDate: widget.event['date'] ?? 'Date not specified',
            eventLocation: widget.event['location'] ?? 'Venue not specified',
            userName: widget.userName,
            userContact: widget.userPhone,
            bookingId: bookingId,
          ),
        ),
      );

      /* Uncomment this for actual API call
      final response = await http.post(
        Uri.parse('http://192.168.1.6:8081/api/bookings'),
        body: jsonEncode(bookingData),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Booking response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final bookingId = responseData['bookingId'] ?? 
            "BK-${DateTime.now().millisecondsSinceEpoch}";

        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentResultPopup(
              eventName: widget.event['name'],
              eventDate: widget.event['date'] ?? 'Date not specified',
              eventLocation: widget.event['location'] ?? 'Venue not specified',
              userName: widget.userName,
              userContact: widget.userPhone,
              bookingId: bookingId,
            ),
          ),
        );
      } else {
        throw Exception('Booking failed with status ${response.statusCode}');
      }
      */
    } catch (e) {
      debugPrint('Booking Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Booking failed: ${e.toString()}"),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the 6-digit code sent to ${widget.userEmail}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // OTP Input Fields
            GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(_focusNode),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    height: 45,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: index == currentOtpIndex
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        otp[index].isNotEmpty ? '●' : '',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "VERIFY & CONTINUE",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: _isLoading ? null : _generateOtp,
              child: const Text(
                "Resend OTP",
                style: TextStyle(fontSize: 16),
              ),
            ),

            // Hidden text field for keyboard input
            Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
