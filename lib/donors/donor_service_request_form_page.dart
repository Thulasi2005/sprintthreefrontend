import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonorRequestForm extends StatefulWidget {
  @override
  _DonorRequestFormState createState() => _DonorRequestFormState();
}

class _DonorRequestFormState extends State<DonorRequestForm> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _donorName = '';
  String _donorContactNumber = '';
  String _donorOccupation = '';
  String _donorNationalIdentityNumber = '';
  String _selectedPurpose = '';
  String _description = '';
  String _timePeriod = '';
  bool _userAgreement = false;

  bool _isSubmitted = false;
  Map<String, String>? _submittedData;

  // Submit form function
  void _submitForm() async {
    if (_formKey.currentState!.validate() && _userAgreement) {
      _formKey.currentState!.save();

      // Create the data to be sent to the backend
      Map<String, dynamic> formData = {
        'donor_name': _donorName,
        'donor_contact_number': _donorContactNumber,
        'donor_occupation': _donorOccupation,
        'donor_national_identity_number': _donorNationalIdentityNumber,
        'purpose': _selectedPurpose,
        'description': _description,
        'time_period': _timePeriod,
      };

      // Send a POST request to the backend
      var response = await http.post(
        Uri.parse('http://10.3.1.240/donation_App/submit_donor_request.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          setState(() {
            _isSubmitted = true;
            _submittedData = formData.map((key, value) => MapEntry(key, value.toString()));
          });
        } else {
          // Handle submission error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${responseBody['message']}'),
          ));
        }
      } else {
        // Handle server error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: Could not submit request.'),
        ));
      }
    }
  }

  void _showUserAgreement() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Agreement'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Terms and Conditions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '1. **Acceptance of Terms**: By using this application, you agree to abide by these terms and conditions. If you do not agree with any part of these terms, please do not use the application.',
                ),
                SizedBox(height: 10),
                Text(
                  '2. **User Responsibilities**: You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account.',
                ),
                SizedBox(height: 10),
                Text(
                  '3. **Privacy Policy**: We are committed to protecting your privacy. Our privacy policy outlines how we collect, use, and protect your personal information. Please review our privacy policy for more details.',
                ),
                SizedBox(height: 10),
                Text(
                  '4. **Prohibited Activities**: You agree not to engage in any activities that could harm the application or its users. This includes, but is not limited to, spreading malware, attempting to breach the application’s security, or harassing other users.',
                ),
                SizedBox(height: 10),
                Text(
                  '5. **Changes to Terms**: We reserve the right to modify these terms at any time. Any changes will be communicated to you, and your continued use of the application will constitute acceptance of the updated terms.',
                ),
                SizedBox(height: 10),
                Text(
                  '6. **Limitation of Liability**: We are not liable for any indirect, incidental, or consequential damages that may arise from your use of the application. Our liability is limited to the fullest extent permitted by law.',
                ),
                SizedBox(height: 10),
                Text(
                  '7. **Governing Law**: These terms and conditions are governed by and construed in accordance with the laws of [Your Country/State]. Any disputes arising from these terms will be subject to the exclusive jurisdiction of the courts in [Your Country/State].',
                ),
                SizedBox(height: 10),
                Text(
                  '8. **Contact Information**: If you have any questions about these terms or our privacy policy, please contact us at [Your Contact Information].',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      appBar: AppBar(
        title: Text('Donor Other Services Request Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isSubmitted
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Request Submitted Successfully!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildSummary(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Navigate to home page
              },
              child: Text('Go to Home'),
            ),
          ],
        )
            : Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Donor Name'),
                onSaved: (value) => _donorName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Donor Contact Number'),
                onSaved: (value) => _donorContactNumber = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Donor Occupation'),
                onSaved: (value) => _donorOccupation = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your occupation';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'National Identity Number'),
                onSaved: (value) => _donorNationalIdentityNumber = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your national identity number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Purpose'),
                value: _selectedPurpose.isEmpty ? null : _selectedPurpose,
                items: [
                  'Basic needs',
                  'Medical care',
                  'Facility maintenance',
                  'Staff salaries',
                  'Activity programs',
                  'Emergency fund',
                  'Administrative costs',
                  'Special projects',
                  'Capacity expansion',
                  'Educational and skill development',
                  'Other'
                ].map((purpose) {
                  return DropdownMenuItem<String>(
                    value: purpose,
                    child: Text(purpose),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPurpose = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a purpose';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Time Period'),
                onSaved: (value) => _timePeriod = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time period';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: Text('I agree to the terms and conditions'),
                value: _userAgreement,
                onChanged: (newValue) {
                  setState(() {
                    _userAgreement = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!_userAgreement) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You must agree to the terms and conditions.')),
                    );
                  } else {
                    _showUserAgreement();
                  }
                },
                child: Text('Read Terms and Conditions'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _submittedData!.entries.map((entry) {
        return Text(
          '${entry.key}: ${entry.value}',
          style: TextStyle(fontSize: 16),
        );
      }).toList(),
    );
  }
}
