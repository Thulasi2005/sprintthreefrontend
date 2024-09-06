import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      appBar: AppBar(
        title: Text('About App'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo or relevant image
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Bridge of Hope',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Bridge of Hope is a non-profit organization dedicated to improving the lives of those in need. Our mission is to provide support through donations, collaborations, and community engagement.',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.5, // Line height for better readability
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Our app connects donors with causes they care about, making it easy to contribute and track their impact.',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.5, // Line height for better readability
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),
            // Contact section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[100],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'For more information or inquiries, please email us at:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'info@bridgeofhope.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
