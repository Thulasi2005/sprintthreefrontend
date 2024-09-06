import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For image selection
import 'dart:io';
import 'package:http/http.dart' as http; // For HTTP requests

class PaymentMethodPage extends StatefulWidget {
  final Map<String, dynamic> request;

  PaymentMethodPage({required this.request});

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final _receiptImage = ValueNotifier<XFile?>(null);
  final _donorNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _addressController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    _receiptImage.value = pickedFile;
  }

  Future<void> _handleSubmit() async {
    if (_receiptImage.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload a receipt')),
      );
      return;
    }

    // Collect donor information
    final donorInfo = {
      'name': _donorNameController.text,
      'contact_number': _contactNumberController.text,
      'address': _addressController.text,
    };

    // Prepare request data
    final requestData = {
      'donor_name': donorInfo['name'] ?? '',
      'contact_number': donorInfo['contact_number'] ?? '',
      'address': donorInfo['address'] ?? '',
      'request_id': widget.request['id']?.toString() ?? '',
    };

    // Perform HTTP request to upload data
    final uri = Uri.parse('http://10.3.1.240/donation_app/upload_donation.php');
    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll(requestData)
      ..files.add(await http.MultipartFile.fromPath('receipt_image', _receiptImage.value!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donation submitted successfully')),
      );
      // Navigate or perform further actions if needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit donation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      appBar: AppBar(
        title: Text('Upload Receipt and Donor Details'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please upload a receipt of the money transfer and provide your details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _donorNameController,
              decoration: InputDecoration(labelText: 'Donor Name'),
            ),
            TextFormField(
              controller: _contactNumberController,
              decoration: InputDecoration(labelText: 'Contact Number'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Receipt Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20.0),
            ValueListenableBuilder<XFile?>(
              valueListenable: _receiptImage,
              builder: (context, image, child) {
                return image == null
                    ? Container()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Receipt:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal[800]),
                    ),
                    SizedBox(height: 10.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(image.path),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                );
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
