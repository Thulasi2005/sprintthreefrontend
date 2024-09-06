import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

class HomeRequestMoneyDonationPage extends StatefulWidget {
  @override
  _HomeRequestMoneyDonationPageState createState() => _HomeRequestMoneyDonationPageState();
}

class _HomeRequestMoneyDonationPageState extends State<HomeRequestMoneyDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _elderlyHomeNameController = TextEditingController();
  final TextEditingController _contactAddressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedPurpose;
  bool _isPrivacyPolicyAccepted = false;
  List<File> _supportingDocuments = [];
  List<File> _selectedImages = [];
  bool _isSummaryVisible = false;

  void _handlePurposeChange(String? newValue) {
    setState(() {
      _selectedPurpose = newValue;
      if (newValue == 'Other') {
        _descriptionController.text = ''; // Clear description if 'Other' is selected
      }
    });
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate() && _isPrivacyPolicyAccepted) {
      // Prepare data
      var uri = Uri.parse('http://10.3.1.240/donation_app/submit_request.php'); // Replace with your backend URL
      var request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['elderly_home_name'] = _elderlyHomeNameController.text;
      request.fields['contact_address'] = _contactAddressController.text;
      request.fields['contact_number'] = _contactNumberController.text;
      request.fields['amount'] = _amountController.text;
      request.fields['purpose'] = _selectedPurpose ?? '';
      request.fields['description'] = _descriptionController.text;

      // Add supporting documents
      for (var file in _supportingDocuments) {
        var mimeType = mime(file.path) ?? 'application/octet-stream';
        var fileStream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          'supporting_documents[]',
          fileStream,
          length,
          filename: file.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      // Add selected images
      for (var image in _selectedImages) {
        var mimeType = mime(image.path) ?? 'image/jpeg';
        var fileStream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile(
          'selected_images[]',
          fileStream,
          length,
          filename: image.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      // Send the request
      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          // Handle success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Request submitted successfully')),
          );
        } else {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit request')),
          );
        }
      } catch (e) {
        // Handle exception
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } else if (!_isPrivacyPolicyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please accept the Privacy Policy')),
      );
    }
  }

  void _showRequestSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Request Summary'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elderly Home Name: ${_elderlyHomeNameController.text}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Contact Address: ${_contactAddressController.text}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Contact Number: ${_contactNumberController.text}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Amount Required (LKR): ${_amountController.text}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Purpose: ${_selectedPurpose ?? 'N/A'}',
                  style: TextStyle(fontSize: 18),
                ),
                if (_descriptionController.text.isNotEmpty)
                  Text(
                    'Description: ${_descriptionController.text}',
                    style: TextStyle(fontSize: 18),
                  ),
                if (_supportingDocuments.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Supporting Documents:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ..._supportingDocuments.map((file) => Text(file.path.split('/').last)).toList(),
                    ],
                  ),
                if (_selectedImages.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Selected Images:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 100, // Fixed height for image preview area
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _selectedImages.map((image) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.file(image, width: 100, height: 100),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc'],
    );

    if (result != null) {
      setState(() {
        _supportingDocuments = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  void _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null) {
      setState(() {
        _selectedImages = images.map((image) => File(image.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Money Donation Request',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Request Money Donation',
                  style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Elderly Home Name',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _elderlyHomeNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the elderly home name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Contact Address',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _contactAddressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the contact address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Contact Number',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Amount Required (LKR)',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Purpose of Donation',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedPurpose,
                onChanged: _handlePurposeChange,
                items: [
                  'Basic needs (food, clothing, hygiene products)',
                  'Medical care (treatments, medications, check-ups)',
                  'Facility maintenance (repairs, renovations, upgrades)',
                  'Staff salaries (caregivers, nurses, support staff)',
                  'Activity programs (recreational and social activities)',
                  'Emergency fund (unexpected expenses, urgent repairs)',
                  'Administrative costs (operational expenses)',
                  'Special projects (improving accessibility, comfort zones)',
                  'Capacity expansion (accommodating more residents, additional services)',
                  'Educational and skill development (programs for staff and residents)',
                  'Other'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a purpose';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (_selectedPurpose == 'Other')
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _pickFiles,
                    child: Text('Pick Supporting Documents'),
                  ),
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: Text('Pick Images'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isPrivacyPolicyAccepted,
                    onChanged: (value) {
                      setState(() {
                        _isPrivacyPolicyAccepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'I accept the Privacy Policy',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitRequest,
                child: Text('Submit Request'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showRequestSummary,
                child: Text('Show Request Summary'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
