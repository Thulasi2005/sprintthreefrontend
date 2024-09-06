import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donation App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomeItemDonationRequestPage(),
    );
  }
}

class HomeItemDonationRequestPage extends StatefulWidget {
  @override
  _HomeItemDonationRequestPageState createState() =>
      _HomeItemDonationRequestPageState();
}

class _HomeItemDonationRequestPageState
    extends State<HomeItemDonationRequestPage> {
  final Map<String, List<dynamic>> items = {
    'Rice': [0, ''],
    'Sugar': [0, ''],
    'Salt': [0, ''],
    'Dhal': [0, ''],
    'Soya': [0, ''],
    'Vegetable oil': [0, ''],
    'Coconut milk powder': [0, ''],
    'Tea powder': [0, ''],
    'Biscuits': [0, ''],
    'Tin fish': [0, ''],
    'Wheat flour': [0, ''],
    'Noodles': [0, ''],
    'Rice flour': [0, ''],
    'Spices': [0, ''],
    'Milk powder': [0, ''],
    'Oats': [0, ''],
    'Eggs': [0, ''],
    'Yoghurt': [0, ''],
    'Bread': [0, ''],
    'Butter': [0, ''],
    'Jam': [0, ''],
    'Nuts': [0, ''],
    'Toothbrush': [0, ''],
    'Toothpaste': [0, ''],
    'Pampers': [0, ''],
    'Soap': [0, ''],
    'Shampoo': [0, ''],
    'Combs': [0, ''],
    'Face powder': [0, ''],
    'Nail cutter': [0, ''],
    'Bedsheets': [0, ''],
    'Pillows': [0, ''],
    'Slippers': [0, ''],
    'Toilet paper': [0, ''],
    'Hand sanitizer': [0, ''],
    'Tissues': [0, ''],
    'Towel': [0, ''],
    'Face masks': [0, ''],
    'First aid': [0, ''],
  };

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  bool _isRequestButtonEnabled() {
    return _nameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _contactController.text.isNotEmpty &&
        items.values.any((element) => element[0] > 0);
  }

  void _showEditDialog(String item) {
    TextEditingController quantityController = TextEditingController(
      text: items[item]?[0]?.toString() ?? '0',
    );
    TextEditingController descriptionController = TextEditingController(
      text: items[item]?[1]?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    if (items[item] != null && items[item]!.isNotEmpty) {
                      items[item]![0] = int.tryParse(value) ?? 0;
                    }
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    if (items[item] != null && items[item]!.length > 1) {
                      items[item]![1] = value;
                    }
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.keys.map((item) {
        bool isChecked = items[item]?[0] > 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        items[item]![0] = value! ? 1 : 0;
                      });
                    },
                  ),
                  Text(item,
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.teal),
                onPressed: () {
                  _showEditDialog(item);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submitRequest() async {
    final url = 'http://10.3.1.240/donation_app/donation_request.php'; // Update with your actual backend URL for Android Emulator
    final requestBody = {
      'name': _nameController.text,
      'address': _addressController.text,
      'contact': _contactController.text,
      'items': items.entries
          .where((entry) => entry.value[0] > 0)
          .map((entry) => {
        'item': entry.key,
        'quantity': entry.value[0],
        'description': entry.value[1]
      })
          .toList(),
    };

    print('Request body: ${json.encode(requestBody)}'); // Debug line

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}'); // Debug line
      print('Response body: ${response.body}'); // Debug line

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          _showSuccessDialog(
            responseData['request_id'],
            responseData['name'],
            responseData['address'],
            responseData['contact'],
            responseData['items'],
          );
        } else {
          _showErrorDialog(responseData['message']);
        }
      } else {
        _showErrorDialog('Failed to submit request. Please try again.');
      }
    } catch (e) {
      print('Request failed with error: $e');
      _showErrorDialog('Failed to submit request. Please check your connection and try again.');
    }
  }

  void _showSuccessDialog(String requestId, String name, String address,
      String contact, List<dynamic> items) {
    int totalItems = items.length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.teal, size: 100),
              Text(
                'Request Submitted',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Request ID: $requestId',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              Text(
                'Total Items Submitted: $totalItems',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestSummaryPage(
                        requestId: requestId,
                        totalItems: totalItems,
                      ),
                    ),
                  );
                },
                child: Text('VIEW SUMMARY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Request Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Contact',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              Text(
                'Items:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildItemList(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _isRequestButtonEnabled() ? _submitRequest : null,
                  child: Text('SUBMIT REQUEST'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RequestSummaryPage extends StatelessWidget {
  final String requestId;
  final int totalItems;

  RequestSummaryPage({required this.requestId, required this.totalItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request ID: $requestId',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Total Items: $totalItems',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Display other summary details if needed
          ],
        ),
      ),
    );
  }
}
