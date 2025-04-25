import 'package:event_ease/e_ticket_page.dart';
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
  List<String> otp = ['', '', '', '', '', '']; // 6-digit OTP
  int currentOtpIndex = 0;
  bool _isLoading = false;
  String? _debugOtp;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
    super.dispose();
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

  Future<void> _generateOtp() async {
    setState(() {
      _isLoading = true;
      _debugOtp = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.1.6:8081/api/otp/generate?email=${widget.userEmail}'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _debugOtp =
              responseData['debugOtp'] ?? '123456'; // Fallback for testing
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to ${widget.userEmail}'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate OTP')),
        );
      }
    } catch (e) {
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
        SnackBar(content: Text("Please enter complete 6-digit OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.6:8081/api/otp/verify'),
        body: jsonEncode({
          'email': widget.userEmail,
          'otpCode': enteredOtp,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final isValid = jsonDecode(response.body) as bool;
        if (isValid) {
          await _completeBooking();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid OTP. Please try again.")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeBooking() async {
    try {
      final bookingData = {
        'eventId': widget.event['id'],
        'userEmail': widget.userEmail,
        'userName': widget.userName,
        'userPhone': widget.userPhone,
        'seatCount': widget.seatCount,
        'totalAmount': widget.totalAmount,
        'bookingTime': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('http://192.168.1.6:8081/api/bookings'),
        body: jsonEncode(bookingData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ETicketPage(
                // event: widget.event,
                // userName: widget.userName,
                // userEmail: widget.userEmail,
                // seatCount: widget.seatCount,
                // bookingId: "BK-${DateTime.now().millisecondsSinceEpoch}",
                ),
          ),
        );
      } else {
        throw Exception('Booking failed with status ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: ${e.toString()}")),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify OTP"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the 6-digit code sent to",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              widget.userEmail,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),

            // OTP Input Fields
            GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(_focusNode),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    height: 45,
                    margin: EdgeInsets.symmetric(horizontal: 5),
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
                        style: TextStyle(
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
            SizedBox(height: 20),

            // Debug OTP (for development only)
            if (_debugOtp != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'DEV OTP: $_debugOtp',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "VERIFY & CONTINUE",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: _isLoading ? null : _generateOtp,
              child: Text(
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
