import 'package:flutter/material.dart';
import 'e_ticket_page.dart'; // Ensure this import is correct

class PaymentResultPopup extends StatelessWidget {
  final bool isSuccess;
  final String eventName;

  const PaymentResultPopup({
    super.key,
    required this.isSuccess,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    final String title = isSuccess ? 'Congratulations!' : 'Oops, Failed!';
    final String message = isSuccess
        ? 'You have successfully placed an order for $eventName.\nEnjoy the event!'
        : 'Your payment failed.\nPlease check your internet connection then try again.';
    final Color highlightColor = isSuccess ? Colors.blue : Colors.pink;
    final String imagePath =
        isSuccess ? 'assets/images/tick.png' : 'assets/images/cross.png';
    final String mainButtonText = isSuccess ? 'View E-Ticket' : 'Try Again';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: highlightColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    isSuccess ? Icons.check : Icons.close,
                    size: 50,
                    color: highlightColor,
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: highlightColor),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: highlightColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (isSuccess) {
                    Navigator.pop(context); // Close the popup
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ETicketPage()),
                    );
                  } else {
                    Navigator.pop(context); // Close the popup
                  }
                },
                child: Text(mainButtonText),
              ),
              SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
