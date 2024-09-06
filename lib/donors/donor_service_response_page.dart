import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonorServiceResponsePage extends StatefulWidget {
  @override
  _DonorServiceResponsePageState createState() => _DonorServiceResponsePageState();
}

class _DonorServiceResponsePageState extends State<DonorServiceResponsePage> {
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
      final response = await http.get(Uri.parse('http://10.3.1.240/donation_app/get_service_requests.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data fetched: $data'); // Debug line to check data

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

  Future<void> _updateRequestStatus(int requestId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.3.1.240/donation_app/update_request_service_status.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': requestId,
          'status': status,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          print('Request updated successfully.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Request updated successfully.')),
          );
          await _fetchRequests(); // Refresh the list after update
        } else {
          print('Failed to update request: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update request: ${result['message']}')),
          );
        }
      } else {
        print('Failed to update request. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update request. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error updating request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Service Requests'),
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

          // Handle null status and provide a default value
          String currentStatus = request['status']?.toString() ?? 'Pending';

          // Check if the request has been accepted or declined
          bool isEditable = currentStatus != 'Accepted' && currentStatus != 'Declined';

          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Home Name: ${request['homeName']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Service: ${request['service']}'),
                  Text('Number of Elders: ${request['numElders']}'),
                  Text('Description: ${request['description']}'),
                  Text('Time Period: ${request['timePeriod']}'),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: currentStatus,
                    items: ['Pending', 'Accepted', 'Declined']
                        .map<DropdownMenuItem<String>>((String value) {
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
