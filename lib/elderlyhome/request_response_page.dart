import 'package:flutter/material.dart';

class RequestResponsePage extends StatelessWidget {
  final Map<String, dynamic> donorDetails;

  RequestResponsePage({required this.donorDetails});

  @override
  Widget build(BuildContext context) {
    final status = donorDetails['status'];
    final details = donorDetails['details'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Request Response'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Response Status:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              status == 'accepted'
                  ? 'The request has been accepted.'
                  : status == 'collaborated'
                  ? 'The request is being collaborated on.'
                  : 'Unknown status.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            if (status == 'accepted') ...[
              Text(
                'Donor Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Name: ${details['name']}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Email: ${details['email']}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Phone: ${details['phone']}',
                style: TextStyle(fontSize: 18),
              ),
              // Add other donor details if needed
            ],
            if (status == 'collaborated') ...[
              Text(
                'Collaboration Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'The request is being collaborated on. Further details will be provided soon.',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
