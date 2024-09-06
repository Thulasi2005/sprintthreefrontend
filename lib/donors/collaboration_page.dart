import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CollaborationPage extends StatefulWidget {
  final String collaborationRoomId;

  CollaborationPage({required this.collaborationRoomId});

  @override
  _CollaborationPageState createState() => _CollaborationPageState();
}

class _CollaborationPageState extends State<CollaborationPage> {
  Map<String, dynamic>? requestDetails;
  List<dynamic> items = [];
  Set<String> selectedItems = Set();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCollaborationDetails();
  }

  Future<void> _fetchCollaborationDetails() async {
    final url = 'http://10.3.1.240/donation_app/get_collaboration_details.php'; // Update with your actual backend URL
    final requestBody = json.encode({'collaboration_room_id': widget.collaborationRoomId});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> && responseData['request'] != null) {
          setState(() {
            requestDetails = responseData['request'];
            items = responseData['items'] ?? [];
            isLoading = false;
          });
        } else {
          _showErrorDialog('Details not found.');
        }
      } else {
        _showErrorDialog('Failed to fetch details. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch details. Please check your connection and try again.');
    }
  }

  void _updateSelectedItems(String itemId, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedItems.add(itemId);
        print('Item $itemId selected.');
      } else {
        selectedItems.remove(itemId);
        print('Item $itemId deselected.');
      }
    });
    print('Selected items: $selectedItems');
  }

  Future<void> _confirmSelection() async {
    final url = 'http://10.3.1.240/donation_app/confirm_selection.php'; // Update with your actual backend URL
    final requestBody = json.encode({
      'collaboration_room_id': widget.collaborationRoomId,
      'selected_items': selectedItems.toList(),
    });

    print('Request Body: $requestBody'); // Debugging output

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('Response: ${response.body}'); // Debugging output

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> && responseData['status'] == 'success') {
          _showSuccessDialog('Selection confirmed successfully.');
        } else {
          _showErrorDialog('Failed to confirm selection. Please try again.');
        }
      } else {
        _showErrorDialog('Failed to confirm selection. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Failed to confirm selection. Please check your connection and try again.');
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
          title: Text('Collaboration Details'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (requestDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Collaboration Details'),
        ),
        body: Center(
          child: Text('No details available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Collaboration Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request ID: ${requestDetails!['request_id']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Name: ${requestDetails!['name']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Address: ${requestDetails!['address']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Contact: ${requestDetails!['contact']}',
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
                  final item = items[index];
                  return CheckboxListTile(
                    title: Text(item['item']),
                    subtitle: Text(
                        'Quantity: ${item['quantity']}\nDescription: ${item['description']}'),
                    value: selectedItems.contains(item['id']),
                    onChanged: (bool? value) {
                      print('Checkbox ${item['id']} changed to $value');
                      _updateSelectedItems(item['id'], value ?? false);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmSelection,
              child: Text('Confirm Selection'),
            ),
          ],
        ),
      ),
    );
  }
}
