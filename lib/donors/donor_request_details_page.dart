import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RequestDetailsPage extends StatelessWidget {
  final Map<String, dynamic> request;

  RequestDetailsPage({required this.request});

  Future<void> _updateRequestStatus(BuildContext context, String status) async {
    final response = await http.post(
      Uri.parse('http://10.3.1.240/donation_app/update_moneyrequest_status.php'),
      body: {
        'request_id': request['id'].toString(),
        'status': status,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status successfully')),
      );
      if (status == 'Accepted') {
        Navigator.pushNamed(
          context,
          '/donorpayment',
          arguments: request, // Pass the request as an argument
        );
      } else {
        Navigator.pop(context); // Return to the previous page if declined
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F7FA),
      appBar: AppBar(
        title: Text('Request Details'),
        backgroundColor: Color(0xFF21B2C5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elderly Home Name:',
              style: TextStyle(
                fontSize: 24, // Increased font size
                fontWeight: FontWeight.bold,
                color: Colors.teal[900], // Darker shade
              ),
            ),
            Text(
              request['elderly_home_name'] ?? 'Not Available',
              style: TextStyle(fontSize: 22), // Increased font size
            ),
            SizedBox(height: 16.0), // Increased spacing
            Text(
              'Contact Address:',
              style: TextStyle(
                fontSize: 24, // Increased font size
                fontWeight: FontWeight.bold,
                color: Colors.teal[900], // Darker shade
              ),
            ),
            Text(
              request['contact_address'] ?? 'Not Available',
              style: TextStyle(fontSize: 22), // Increased font size
            ),
            SizedBox(height: 16.0), // Increased spacing
            Text(
              'Contact Number:',
              style: TextStyle(
                fontSize: 24, // Increased font size
                fontWeight: FontWeight.bold,
                color: Colors.teal[900], // Darker shade
              ),
            ),
            Text(
              request['contact_number'] ?? 'Not Available',
              style: TextStyle(fontSize: 22), // Increased font size
            ),
            SizedBox(height: 16.0), // Increased spacing
            Text(
              'Amount Required:',
              style: TextStyle(
                fontSize: 24, // Increased font size
                fontWeight: FontWeight.bold,
                color: Colors.teal[900], // Darker shade
              ),
            ),
            Text(
              '${request['amount_required'] ?? 'Not Available'} LKR',
              style: TextStyle(fontSize: 22), // Increased font size
            ),
            SizedBox(height: 16.0), // Increased spacing
            Text(
              'Purpose:',
              style: TextStyle(
                fontSize: 24, // Increased font size
                fontWeight: FontWeight.bold,
                color: Colors.teal[900], // Darker shade
              ),
            ),
            Text(
              request['purpose'] ?? 'Not Available',
              style: TextStyle(fontSize: 22), // Increased font size
            ),
            SizedBox(height: 16.0), // Increased spacing
            if (request['description'] != null && request['description']!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 24, // Increased font size
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900], // Darker shade
                    ),
                  ),
                  Text(
                    request['description'] ?? 'No Description',
                    style: TextStyle(fontSize: 22), // Increased font size
                  ),
                  SizedBox(height: 16.0), // Increased spacing
                ],
              ),
            if (request['supporting_documents'] != null && request['supporting_documents']!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supporting Documents:',
                    style: TextStyle(
                      fontSize: 24, // Increased font size
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900], // Darker shade
                    ),
                  ),
                  ...request['supporting_documents']!.split(',').map((doc) => Text(doc, style: TextStyle(fontSize: 22))).toList(), // Increased font size
                  SizedBox(height: 16.0), // Increased spacing
                ],
              ),
            if (request['selected_images'] != null && request['selected_images']!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Images:',
                    style: TextStyle(
                      fontSize: 24, // Increased font size
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900], // Darker shade
                    ),
                  ),
                  // Add code to display images, such as using Image.network() or similar
                  // For example:
                  ...request['selected_images']!.split(',').map((url) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.network(url, height: 120, width: 120, fit: BoxFit.cover), // Increased image size
                  )).toList(),
                ],
              ),
            SizedBox(height: 32.0), // Increased spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _updateRequestStatus(context, 'Accepted'),
                  child: Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 28.0), // Increased padding
                    textStyle: TextStyle(fontSize: 18), // Increased font size
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _updateRequestStatus(context, 'Declined'),
                  child: Text('Decline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 28.0), // Increased padding
                    textStyle: TextStyle(fontSize: 18), // Increased font size
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
