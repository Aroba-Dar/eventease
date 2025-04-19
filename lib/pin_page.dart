import 'package:event_ease/payment_result_page.dart';
import 'package:flutter/material.dart';

class EnterPinPage extends StatefulWidget {
  const EnterPinPage({super.key});

  @override
  _EnterPinPageState createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  final String correctPin = "1234"; // Update this as needed
  List<String> pin = ['', '', '', ''];
  int currentPinIndex = 0;

  // Controller & FocusNode for the invisible TextField
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    _controller.addListener(() {
      final text = _controller.text;
      if (text.length > 4) {
        _controller.text = text.substring(0, 4);
        _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length));
      }
      setState(() {
        for (int i = 0; i < 4; i++) {
          pin[i] = i < text.length ? text[i] : '';
        }
        currentPinIndex = text.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showPaymentResult(bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: PaymentResultPopup(
            isSuccess: isSuccess,
            eventName: "National Music Festival",
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Your PIN"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter your PIN to confirm payment"),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(_focusNode);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: index == currentPinIndex
                            ? Colors.purple
                            : Colors.grey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        pin[index].isNotEmpty ? '●' : '',
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final typedPin = pin.join();

                if (typedPin.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter 4 digits")),
                  );
                  return;
                }

                _showPaymentResult(typedPin == correctPin);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Continue"),
            ),
            SizedBox(height: 20),
            Opacity(
              opacity: 0.0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
