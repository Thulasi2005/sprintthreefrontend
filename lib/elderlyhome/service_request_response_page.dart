import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiceRequest {
  final int id;
  final String? homeName;
  final String? contactNumber;
  final String? address;
  final int numElders;
  final String? service;
  final String? description;
  final String? timePeriod;
  final String? status;

  ServiceRequest({
    required this.id,
    this.homeName,
    this.contactNumber,
    this.address,
    required this.numElders,
    this.service,
    this.description,
    this.timePeriod,
    this.status,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: int.parse(json['id'].toString()), // Convert to int
      homeName: json['homeName'] as String?, // Nullable String
      contactNumber: json['contactNumber'] as String?, // Nullable String
      address: json['address'] as String?, // Nullable String
      numElders: int.parse(json['numElders'].toString()), // Convert to int
      service: json['service'] as String?, // Nullable String
      description: json['description'] as String?, // Nullable String
      timePeriod: json['timePeriod'] as String?, // Nullable String
      status: json['status'] as String?, // Nullable String
    );
  }
}

class ServiceRequestsPage extends StatefulWidget {
  @override
  _ServiceRequestsPageState createState() => _ServiceRequestsPageState();
}

class _ServiceRequestsPageState extends State<ServiceRequestsPage> {
  late Future<List<ServiceRequest>> futureServiceRequests;

  @override
  void initState() {
    super.initState();
    futureServiceRequests = fetchServiceRequests();
  }

  Future<List<ServiceRequest>> fetchServiceRequests() async {
    final response = await http.get(Uri.parse('http://10.3.1.240/donation_App/get_service_requests_update.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ServiceRequest.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load service requests');
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
        title: Text('Service Requests'),
      ),
      body: FutureBuilder<List<ServiceRequest>>(
        future: futureServiceRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No service requests found'));
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
                      request.homeName ?? 'Unknown Home Name',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact: ${request.contactNumber ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                        Text('Address: ${request.address ?? 'N/A'}', style: TextStyle(color: Colors.black)),
                        Text('Elders: ${request.numElders}', style: TextStyle(color: Colors.black)),
                        Text('Service: ${request.service ?? 'N/A'}', style: TextStyle(color: Colors.black)),
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
