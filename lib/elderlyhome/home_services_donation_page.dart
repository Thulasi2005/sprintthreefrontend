import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiceRequestPage extends StatefulWidget {
  @override
  _ServiceRequestPageState createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _homeNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _numEldersController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timePeriodController = TextEditingController();
  bool _agreementAccepted = false;

  String? _selectedService;
  List<String> _services = [
    'Medical Support',
    'Food Supply',
    'Hygiene Products',
    'Clothing',
    'Facility Maintenance',
    'Staff Salaries',
    'Activity Programs',
    'Emergency Fund',
    'Administrative Costs',
    'Special Projects',
    'Capacity Expansion',
    'Educational and Skill Development',
    'Other'
  ];

  Map<String, String>? _submittedData;

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate() && _agreementAccepted) {
      final response = await http.post(
        Uri.parse('http://10.3.1.240/donation_app/submit_service_request.php'),
        body: {
          'homeName': _homeNameController.text.trim(),
          'contactNumber': _contactNumberController.text.trim(),
          'address': _addressController.text.trim(),
          'numElders': _numEldersController.text.trim(),
          'service': _selectedService ?? '',
          'description': _descriptionController.text.trim(),
          'timePeriod': _timePeriodController.text.trim(),
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final result = jsonDecode(response.body);
      if (result['success']) {
        setState(() {
          _submittedData = {
            'homeName': _homeNameController.text.trim(),
            'contactNumber': _contactNumberController.text.trim(),
            'address': _addressController.text.trim(),
            'numElders': _numEldersController.text.trim(),
            'service': _selectedService ?? '',
            'description': _descriptionController.text.trim(),
            'timePeriod': _timePeriodController.text.trim(),
          };
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: ${result['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and accept the agreement')),
      );
    }
  }

  Widget _buildSummaryView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary of Request:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Home Name: ${_submittedData!['homeName']}'),
          Text('Contact Number: ${_submittedData!['contactNumber']}'),
          Text('Address: ${_submittedData!['address']}'),
          Text('Number of Elders: ${_submittedData!['numElders']}'),
          Text('Service Requested: ${_submittedData!['service']}'),
          Text('Description: ${_submittedData!['description']}'),
          Text('Time Period: ${_submittedData!['timePeriod']}'),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/elderlyHomeHomePage');
              },
              child: Text('Go to Home Page'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Service Donation'),
        backgroundColor: Color(0xFF21B2C5),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: _submittedData == null
            ? Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _homeNameController,
                decoration: InputDecoration(labelText: 'Home Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the home name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the contact number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _numEldersController,
                decoration: InputDecoration(labelText: 'Number of Elders'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of elders';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Service Requested'),
                value: _selectedService,
                items: _services.map((service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedService = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a service';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _timePeriodController,
                decoration: InputDecoration(labelText: 'Time Period'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the time period';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Checkbox(
                    value: _agreementAccepted,
                    onChanged: (value) {
                      setState(() {
                        _agreementAccepted = value!;
                      });
                    },
                  ),
                  Text('I accept the user agreement'),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  ),
                  child: Text('Submit Request'),
                ),
              ),
            ],
          ),
        )
            : _buildSummaryView(),
      ),
    );
  }
}
