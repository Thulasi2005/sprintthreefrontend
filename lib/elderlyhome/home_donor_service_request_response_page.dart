import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonorRequestsPage extends StatefulWidget {
  @override
  _DonorRequestsPageState createState() => _DonorRequestsPageState();
}

class _DonorRequestsPageState extends State<DonorRequestsPage> {
  List<dynamic> _requests = [];
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isFetching = true;
    });

    try {
      final response = await http.get(Uri.parse('http://10.3.1.240/donation_app/get_donor_requests.php'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched data: $data'); // Debug print

        if (data is List) {
          setState(() {
            _requests = data;
          });
        } else {
          print('Unexpected data format: ${response.body}');
          setState(() {
            _requests = [];
          });
        }
      } else {
        print('Failed to load requests: ${response.statusCode}');
        setState(() {
          _requests = [];
        });
      }
    } catch (e) {
      print('Error fetching requests: $e');
      setState(() {
        _requests = [];
      });
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  Future<void> _updateRequestStatus(dynamic requestId, String status) async {
    // Ensure requestId is an integer
    final int id = int.tryParse(requestId.toString()) ?? -1;
    if (id == -1) {
      print('Invalid request ID: $requestId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid request ID.')),
      );
      return;
    }

    try {
      print('Updating request with ID: $id to status: $status');

      final response = await http.post(
        Uri.parse('http://10.3.1.240/donation_app/update_donor_request_status.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Update response: $result'); // Debug print

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Request updated successfully.')),
          );
          await _fetchRequests(); // Refresh the list after update
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update request: ${result['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update request. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Donor Requests'),
        backgroundColor: Color(0xFF21B2C5),
      ),
      body: _isFetching
          ? Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(child: Text('No requests available'))
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          String currentStatus = request['status']?.toString() ?? 'Pending';

          // Debug prints
          print('Request ID: ${request['id']}');
          print('Current Status: $currentStatus');

          // Ensure unique dropdown items
          const statusOptions = ['Pending', 'Accepted', 'Declined'];

          // Check if the request has been accepted or declined
          bool isEditable = currentStatus != 'Accepted' && currentStatus != 'Declined';

          // Handle the case where currentStatus might not be in statusOptions
          String dropdownValue = statusOptions.contains(currentStatus) ? currentStatus : statusOptions[0];

          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Donor Name: ${request['donor_name'] ?? 'N/A'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Contact Number: ${request['donor_contact_number'] ?? 'N/A'}'),
                  Text('Occupation: ${request['donor_occupation'] ?? 'N/A'}'),
                  Text('National Identity Number: ${request['donor_national_identity_number'] ?? 'N/A'}'),
                  Text('Purpose: ${request['purpose'] ?? 'N/A'}'),
                  Text('Description: ${request['description'] ?? 'N/A'}'),
                  Text('Time Period: ${request['time_period'] ?? 'N/A'}'),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: isEditable ? dropdownValue : null,
                    items: statusOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: isEditable
                        ? (String? newValue) async {
                      if (newValue != null && newValue != currentStatus) {
                        await _updateRequestStatus(request['id'], newValue);
                      }
                    }
                        : null, // Disable dropdown if not editable
                    disabledHint: Text(currentStatus), // Show current status if disabled
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
