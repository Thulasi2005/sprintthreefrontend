import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need Assistance?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'If you have any questions or need support, please reach out to us using the options below:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Implement chat functionality
                _startChat(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Button color
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white, width: 2),
                ),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              child: Text('Chat with Administration'),
            ),
            SizedBox(height: 20),
            Text(
              'Alternatively, you can email us directly:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _sendEmail,
              child: Text(
                'Email: admin@bridgeofhope.com',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context) {
    // Placeholder for chat functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chat with Administration'),
          content: Text('Chat feature is coming soon. Please contact us via email for now.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'admin@bridgeofhope.com',
      query: Uri.encodeQueryComponent('Subject=Support Request&Body=Hello, I need help with...'),
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      // Show an error message if email client cannot be opened
      throw 'Could not open email client.';
    }
  }
}
