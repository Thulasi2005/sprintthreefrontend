import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ElderlyHomeRegistrationPage extends StatefulWidget {
  @override
  _ElderlyHomeRegistrationPageState createState() => _ElderlyHomeRegistrationPageState();
}

class _ElderlyHomeRegistrationPageState extends State<ElderlyHomeRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTermsAccepted = false;
  int _numberOfElders = 1;
  String _selectedDistrict = 'Colombo';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nationalIdentityNumberController = TextEditingController();
  final TextEditingController _roleOrJobTitleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _submitRegistration() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await http.post(
          Uri.parse('http://10.3.1.240/donation_app/register_elderly_home.php'),
          body: {
            'name': _nameController.text,
            'address': _addressController.text,
            'contact_number': _contactNumberController.text,
            'number_of_elders': _numberOfElders.toString(),
            'registration_number': _registrationNumberController.text,
            'district': _selectedDistrict,
            'email': _emailController.text,
            'full_name': _fullNameController.text,
            'national_identity_number': _nationalIdentityNumberController.text,
            'role_or_job_title': _roleOrJobTitleController.text,
            'terms_accepted': _isTermsAccepted ? '1' : '0',
            'username': _usernameController.text,
            'password': _passwordController.text,
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['success']) {
            Navigator.pushNamed(context, '/signUpSuccess');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Registration failed')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode} - ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed. Please try again later. Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      appBar: AppBar(
        title: Text('Elderly Home Registration'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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
                _buildSectionTitle('ELDERLY HOME INFORMATION', Icons.home),
                _buildTextField('Name', _nameController),
                _buildTextField('Address', _addressController),
                _buildTextField('Contact Number', _contactNumberController),
                _buildNumberOfEldersField(),
                _buildTextField('Registration Number', _registrationNumberController),
                _buildDropdown(
                  'District',
                  _selectedDistrict,
                      (String? newValue) {
                    setState(() {
                      _selectedDistrict = newValue!;
                    });
                  },
                  ['Colombo', 'Gampaha', 'Kalutara'],
                ),
                _buildTextField('Email Address', _emailController),
                SizedBox(height: 20),
                _buildSectionTitle('ELDERLY HOME PERSONAL DETAILS', Icons.person),
                _buildTextField('Full Name', _fullNameController),
                _buildTextField('National Identity Number', _nationalIdentityNumberController),
                _buildTextField('Role or Job Title', _roleOrJobTitleController),
                _buildTextField('Contact Number', _contactNumberController),
                SizedBox(height: 20),
                _buildSectionTitle('ACCOUNT DETAILS', Icons.account_circle),
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
                    onPressed: _isTermsAccepted ? _submitRegistration : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      textStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text('SIGN UP'),
                  ),
                ),
              ],
            ),
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
      child: TextFormField(
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'Email Address' && !RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$").hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordTextField(String label, TextEditingController controller, bool obscureText, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'Confirm Password' && value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNumberOfEldersField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value: _numberOfElders,
        decoration: InputDecoration(
          labelText: 'Number of Elders',
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
        items: List.generate(100, (index) => index + 1).map((value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString(), style: TextStyle(fontSize: 18)),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _numberOfElders = newValue!;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select the number of elders';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String value, ValueChanged<String?> onChanged, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
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
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: TextStyle(fontSize: 18)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'Please select $label';
          }
          return null;
        },
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
            child: Text(
              'Here are the terms and conditions...',
              style: TextStyle(fontSize: 16),
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
}
