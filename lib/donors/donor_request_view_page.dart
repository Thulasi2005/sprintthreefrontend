import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestViewPage extends StatefulWidget {
  final String requestId;

  RequestViewPage({required this.requestId});

  @override
  _RequestViewPageState createState() => _RequestViewPageState();
}

class _RequestViewPageState extends State<RequestViewPage> {
  Map<String, dynamic>? requestDetails;
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails();
  }

  Future<void> _fetchRequestDetails() async {
    final url = 'http://10.3.1.240/donation_app/get_request_details.php';
    final requestBody = json.encode({'request_id': widget.requestId});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Debug print for response
        print('Response Data: $responseData');

        if (responseData is Map<String, dynamic>) {
          setState(() {
            requestDetails = responseData['request'] as Map<String, dynamic>? ?? {};
            items = responseData['items'] as List<dynamic>? ?? [];
            isLoading = false;
          });
        } else {
          _showErrorDialog('Request details not found.');
        }
      } else {
        _showErrorDialog('Failed to fetch request details. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch request details. Please check your connection and try again.');
    }
  }

  Future<void> _createCollaborationRoom() async {
    final url = 'http://10.3.1.240/donation_app/create_collaboration_room.php';
    final requestBody = json.encode({'request_id': widget.requestId});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> && responseData['status'] == 'success') {
          final collaborationRoomId = responseData['collaboration_room_id'] as String;
          Navigator.pushNamed(context, '/collaborationdonors', arguments: collaborationRoomId);
        } else {
          _showErrorDialog('Failed to create collaboration room. Please try again.');
        }
      } else {
        _showErrorDialog('Failed to create collaboration room. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Failed to create collaboration room. Please check your connection and try again.');
    }
  }

  Future<void> _updateRequestStatus(String status) async {
    final url = 'http://10.3.1.240/donation_app/update_request_status.php';
    final requestBody = json.encode({
      'request_id': widget.requestId,
      'status': status,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> && responseData['status'] == 'success') {
          _showSuccessDialog('Request $status successfully.');
        } else {
          _showErrorDialog('Failed to $status request. Please try again.');
        }
      } else {
        _showErrorDialog('Failed to $status request. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Failed to $status request. Please check your connection and try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Navigate back to the previous screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Request Details'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (requestDetails == null || requestDetails!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Request Details'),
        ),
        body: Center(
          child: Text('No details available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Request Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request ID: ${requestDetails!['request_id'] ?? 'N/A'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Name: ${requestDetails!['name'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Address: ${requestDetails!['address'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Contact: ${requestDetails!['contact'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      title: Text(item['item'] ?? 'N/A'), // Updated to use 'item' instead of 'name'
                      subtitle: Text('Quantity: ${item['quantity'] ?? 'N/A'}'),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateRequestStatus('Accepted');
                  },
                  child: Text('Accept'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _updateRequestStatus('Declined');
                  },
                  child: Text('Decline'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _createCollaborationRoom();
                  },
                  child: Text('Collaborate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
