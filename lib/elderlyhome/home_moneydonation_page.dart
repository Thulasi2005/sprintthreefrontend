import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentRequest {
  final int id;
  final String donorName;
  final String contactNumber;
  final String address;
  final String receiptImage;
  final DateTime createdAt;
  final String approvalStatus;

  PaymentRequest({
    required this.id,
    required this.donorName,
    required this.contactNumber,
    required this.address,
    required this.receiptImage,
    required this.createdAt,
    required this.approvalStatus,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: int.parse(json['id'].toString()),
      donorName: json['donor_name'] as String,
      contactNumber: json['contact_number'] as String,
      address: json['address'] as String,
      receiptImage: json['receipt_image'] as String,
      createdAt: DateTime.parse(json['created_at']),
      approvalStatus: json['approval_status'] as String,
    );
  }

  Future<void> updateStatus(String newStatus) async {
    final response = await http.post(
      Uri.parse('http://10.3.1.240/donation_App/update_payment_request_status.php'),
      body: json.encode({
        'id': id,
        'approval_status': newStatus,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }
}

class DonationRequest {
  final String elderlyHomeName;
  final String contactAddress;
  final String contactNumber;
  final double amountRequired;
  final String purpose;
  final String? description;
  final String? supportingDocuments;
  final String? selectedImages;
  final DateTime createdAt;
  final String status;

  DonationRequest({
    required this.elderlyHomeName,
    required this.contactAddress,
    required this.contactNumber,
    required this.amountRequired,
    required this.purpose,
    this.description,
    this.supportingDocuments,
    this.selectedImages,
    required this.createdAt,
    required this.status,
  });

  factory DonationRequest.fromJson(Map<String, dynamic> json) {
    return DonationRequest(
      elderlyHomeName: json['elderly_home_name'] as String,
      contactAddress: json['contact_address'] as String,
      contactNumber: json['contact_number'] as String,
      amountRequired: double.parse(json['amount_required'].toString()),
      purpose: json['purpose'] as String,
      description: json['description'] as String?,
      supportingDocuments: json['supporting_documents'] as String?,
      selectedImages: json['selected_images'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] as String,
    );
  }
}

class DonationAndPaymentPage extends StatefulWidget {
  @override
  _DonationAndPaymentPageState createState() => _DonationAndPaymentPageState();
}

class _DonationAndPaymentPageState extends State<DonationAndPaymentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<DonationRequest>> futureDonationRequests;
  late Future<List<PaymentRequest>> futurePaymentRequests;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    futureDonationRequests = fetchDonationRequests();
    futurePaymentRequests = fetchPaymentRequests();
  }

  Future<List<DonationRequest>> fetchDonationRequests() async {
    try {
      final response = await http.get(Uri.parse('http://10.3.1.240/donation_App/get_money_donation_requests.php'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => DonationRequest.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load donation requests');
      }
    } catch (e) {
      throw Exception('Failed to load donation requests: $e');
    }
  }

  Future<List<PaymentRequest>> fetchPaymentRequests() async {
    try {
      final response = await http.get(Uri.parse('http://10.3.1.240/donation_App/get_payment_requests.php'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => PaymentRequest.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load payment requests');
      }
    } catch (e) {
      throw Exception('Failed to load payment requests: $e');
    }
  }

  Color _getStatusColor(String status) {
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

  Color _getApprovalStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'unapproved':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(PaymentRequest request, String status) async {
    try {
      await request.updateStatus(status);
      setState(() {
        futurePaymentRequests = fetchPaymentRequests(); // Refresh the list after update
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation & Payment Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Donations'),
            Tab(text: 'Payments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Donations Page
          FutureBuilder<List<DonationRequest>>(
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
                          request.elderlyHomeName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact Address: ${request.contactAddress}'),
                            Text('Contact Number: ${request.contactNumber}'),
                            Text('Amount Required: \$${request.amountRequired.toStringAsFixed(2)}'),
                            Text('Purpose: ${request.purpose}'),
                            if (request.description != null) Text('Description: ${request.description}'),
                            if (request.supportingDocuments != null) Text('Supporting Documents: ${request.supportingDocuments}'),
                            if (request.selectedImages != null) Text('Selected Images: ${request.selectedImages}'),
                            Text('Created At: ${request.createdAt.toLocal()}'.split(' ')[0]),
                          ],
                        ),
                        trailing: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: _getStatusColor(request.status),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            request.status,
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
          // Payments Page
          FutureBuilder<List<PaymentRequest>>(
            future: futurePaymentRequests,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No payment requests found'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final request = snapshot.data![index];
                    bool isApproved = request.approvalStatus == 'approved';
                    bool isUnapproved = request.approvalStatus == 'unapproved';

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(12.0),
                            title: Text(
                              request.donorName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Contact Number: ${request.contactNumber}'),
                                Text('Address: ${request.address}'),
                                Text('Receipt Image: ${request.receiptImage}'),
                                Text('Created At: ${request.createdAt.toLocal()}'.split(' ')[0]),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: _getApprovalStatusColor(request.approvalStatus),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                request.approvalStatus,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (!isApproved && !isUnapproved)
                            ButtonBar(
                              children: <Widget>[
                                TextButton(
                                  child: Text('Approve'),
                                  onPressed: () => _updateStatus(request, 'approved'),
                                ),
                                TextButton(
                                  child: Text('Decline'),
                                  onPressed: () => _updateStatus(request, 'unapproved'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
