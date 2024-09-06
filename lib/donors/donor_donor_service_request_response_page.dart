import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonationRequest {
  final int id;
  final String? donorName;
  final String? contactNumber;
  final String? occupation;
  final String? nationalIdNumber;
  final String? purpose;
  final String? description;
  final String? timePeriod;
  final String? status;

  DonationRequest({
    required this.id,
    this.donorName,
    this.contactNumber,
    this.occupation,
    this.nationalIdNumber,
    this.purpose,
    this.description,
    this.timePeriod,
    this.status,
  });

  factory DonationRequest.fromJson(Map<String, dynamic> json) {
    return DonationRequest(
      id: int.tryParse(json['id'].toString()) ?? 0,
      donorName: json['donor_name'] as String?,
      contactNumber: json['donor_contact_number'] as String?,
      occupation: json['donor_occupation'] as String?,
      nationalIdNumber: json['donor_national_identity_number'] as String?,
      purpose: json['purpose'] as String?,
      description: json['description'] as String?,
      timePeriod: json['time_period'] as String?,
      status: json['status'] as String?,
    );
  }
}

class DonationRequestsPage extends StatefulWidget {
  @override
  _DonationRequestsPageState createState() => _DonationRequestsPageState();
}

class _DonationRequestsPageState extends State<DonationRequestsPage> {
  late Future<List<DonationRequest>> futureDonationRequests;

  @override
  void initState() {
    super.initState();
    futureDonationRequests = fetchDonationRequests();
  }

  Future<List<DonationRequest>> fetchDonationRequests() async {
    final response = await http.get(Uri.parse('http://10.3.1.240/donation_App/get_donation_requests.php'));

    // Debug print
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => DonationRequest.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load donation requests');
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      appBar: AppBar(
        title: Text('Donation Requests'),
      ),
      body: FutureBuilder<List<DonationRequest>>(
        future: futureDonationRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No donation requests found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final request = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12.0),
                    title: Text(
                      request.donorName ?? 'Unknown Donor Name',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact: ${request.contactNumber ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                        Text('Occupation: ${request.occupation ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                        Text('National ID: ${request.nationalIdNumber ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                        Text('Purpose: ${request.purpose ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                        Text('Description: ${request.description ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                        Text('Time Period: ${request.timePeriod ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        request.status ?? 'Unknown',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
