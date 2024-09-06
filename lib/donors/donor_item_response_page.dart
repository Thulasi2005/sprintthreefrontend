import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonorItemRequestResponsePage extends StatefulWidget {
  @override
  _DonorItemRequestResponsePageState createState() => _DonorItemRequestResponsePageState();
}

class _DonorItemRequestResponsePageState extends State<DonorItemRequestResponsePage> {
  Future<List<dynamic>>? _requestsFuture;
  String? _donorUsername;
  String? _selectedRequestId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _donorUsername = ModalRoute.of(context)?.settings.arguments as String?;
    if (_donorUsername != null) {
      _requestsFuture = _fetchRequests();
    }
  }

  Future<List<dynamic>> _fetchRequests() async {
    final url = 'http://10.3.1.240/donation_app/get_itemrequests.php'; // Your endpoint to get requests
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> requests = json.decode(response.body);
        return requests;
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> _updateRequestStatus(String id, String status) async {
    final url = 'http://10.3.1.240/donation_app/update_item_request_status.php'; // Your endpoint to update status
    final data = {
      'id': id, // Pass id to update status
      'status': status,
      'donor_username': _donorUsername,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        // Refresh the request list
        setState(() {
          _requestsFuture = _fetchRequests();
          _selectedRequestId = null; // Reset selected request
        });
      } else {
        throw Exception('Failed to update request status');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Donation Requests'),
        backgroundColor: Color(0xFF21B2C5),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No requests available'));
          } else {
            final requests = snapshot.data!;
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text('Home Name: ${request['home_name']}'),
                    subtitle: Text('Address: ${request['home_address']}'),
                    children: _selectedRequestId == request['id']
                        ? _buildRequestDetails(request)
                        : [],
                    onExpansionChanged: (expanded) {
                      if (expanded) {
                        setState(() {
                          _selectedRequestId = request['id'];
                        });
                      } else {
                        setState(() {
                          _selectedRequestId = null;
                        });
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildRequestDetails(Map<String, dynamic> request) {
    return [
      ListTile(
        title: Text('Category'),
        subtitle: Text(request['category']),
      ),
      ListTile(
        title: Text('Quantities'),
        subtitle: Text(request['quantities'] ?? 'Not provided'),
      ),
      ListTile(
        title: Text('Descriptions'),
        subtitle: Text(request['descriptions'] ?? 'Not provided'),
      ),
      ListTile(
        title: Text('Emergency'),
        subtitle: Text(request['is_emergency'] == '1' ? 'Yes' : 'No'),
      ),
      ListTile(
        title: Text('Status'),
        subtitle: Text(request['status']),
      ),
      ButtonBar(
        children: [
          TextButton(
            onPressed: () => _updateRequestStatus(request['id'], 'accepted'),
            child: Text('Accept', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () => _updateRequestStatus(request['id'], 'declined'),
            child: Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => _updateRequestStatus(request['id'], 'collaborating'),
            child: Text('Collaborate', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    ];
  }
}
