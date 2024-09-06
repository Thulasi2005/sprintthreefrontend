import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonorRegistrationPage extends StatefulWidget {
  @override
  _DonorRegistrationPageState createState() => _DonorRegistrationPageState();
}

class _DonorRegistrationPageState extends State<DonorRegistrationPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTermsAccepted = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _registerDonor() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    final url = 'http://10.3.1.240/donation_app/register_donor.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'full_name': _fullNameController.text,
          'email': _emailController.text,
          'date_of_birth': _dobController.text,
          'national_identity_number': _identityController.text,
          'contact_number': _contactController.text,
          'permanent_address': _addressController.text,
          'occupation': _occupationController.text,
          'username': _usernameController.text,
          'password': _passwordController.text,
          'terms_accepted': _isTermsAccepted ? '1' : '0',
        },
      );

      // Debugging: Print response status and body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (responseData['success']) {
        Navigator.pushNamed(context, '/signUpSuccess');
      } else {
        _showErrorDialog(responseData['message']);
      }
    } catch (e) {
      // Handle exceptions
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      appBar: AppBar(
        title: Text('Donor Registration'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'CONNECT WITH US!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildSectionTitle('PERSONAL INFORMATION', Icons.person),
              _buildTextField('Full Name', _fullNameController),
              _buildTextField('Email Address', _emailController),
              _buildTextField('Date of Birth', _dobController),
              _buildTextField('National Identity Number', _identityController),
              _buildTextField('Contact Number', _contactController),
              _buildTextField('Permanent Address', _addressController),
              _buildTextField('Occupation (optional)', _occupationController),
              SizedBox(height: 20),
              _buildSectionTitle('ACCOUNT INFORMATION', Icons.account_circle),
              _buildTextField('Username', _usernameController),
              _buildPasswordTextField('Password', _passwordController, _obscurePassword, () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              }),
              _buildPasswordTextField('Confirm Password', _confirmPasswordController, _obscureConfirmPassword, () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              }),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isTermsAccepted,
                    onChanged: (newValue) {
                      setState(() {
                        _isTermsAccepted = newValue!;
                      });
                    },
                    activeColor: Colors.white,
                    checkColor: Colors.teal,
                  ),
                  GestureDetector(
                    onTap: () {
                      _showTermsAndConditions(context);
                    },
                    child: Text(
                      'I agree with the terms and conditions',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isTermsAccepted ? _registerDonor : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    textStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    'SIGN UP',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 18, color: Colors.teal),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildPasswordTextField(String label, TextEditingController controller, bool obscureText, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 18, color: Colors.teal),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.teal,
            ),
            onPressed: toggleVisibility,
          ),
        ),
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms and Conditions'),
          content: SingleChildScrollView(
            child: Text('''
Bridge of Hope - Terms and Conditions

1. Introduction
Welcome to Bridge of Hope, a mobile application designed to connect elderly homes in the Western Province of Sri Lanka with donors across the country. By using our app, you agree to comply with and be bound by the following terms and conditions.

2. Registration and User Accounts
- Eligibility: Users must be at least 18 years old to register.
- Accuracy of Information: Users must provide accurate and complete information during registration.

3. Donor Responsibilities
- Donations: Donors must ensure that the items donated are in good condition.
- Compliance: Donors must comply with all local laws and regulations related to donations.

4. Data Privacy
- Data Collection: We collect personal information to process donations and communicate with users.
- Data Security: We implement reasonable measures to protect your data but cannot guarantee absolute security.

5. Termination
- We reserve the right to terminate or suspend your account if you violate these terms.

6. Limitation of Liability
- We are not liable for any damages resulting from the use of our app or the donation process.

7. Changes to Terms
- We may update these terms from time to time. Your continued use of the app constitutes acceptance of the revised terms.

8. Contact Us
- For any questions or concerns, please contact us at support@bridgeofhope.com.
            '''),
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
}
