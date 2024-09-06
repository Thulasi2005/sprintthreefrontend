import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ElderlyHomeDetails extends StatefulWidget {
  final String username;

  const ElderlyHomeDetails({Key? key, required this.username}) : super(key: key);

  @override
  _ElderlyHomeDetailsState createState() => _ElderlyHomeDetailsState();
}

class _ElderlyHomeDetailsState extends State<ElderlyHomeDetails> {
  Future<Map<String, dynamic>>? _dataFuture;
  bool isError = false;
  String errorMessage = '';
  final _homeNameController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _homeContactNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchElderlyHomeData(widget.username);
  }

  Future<Map<String, dynamic>> _fetchElderlyHomeData(String username) async {
    final url = 'http://10.3.1.240/donation_app/get_elderly_home_data.php?username=$username';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          final data = jsonResponse['data'];
          _homeNameController.text = data['name'] ?? '';
          _homeAddressController.text = data['address'] ?? '';
          _homeContactNumberController.text = data['contact_number'] ?? '';
          return data;
        } else {
          setState(() {
            isError = true;
            errorMessage = jsonResponse['message'];
          });
          return {};
        }
      } else {
        setState(() {
          isError = true;
          errorMessage = 'Failed to load data';
        });
        return {};
      }
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = 'Error: $e';
      });
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elderly Home Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || isError) {
            return Center(child: Text('Error: $errorMessage'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _homeNameController,
                    decoration: InputDecoration(
                      labelText: 'Home Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _homeAddressController,
                    decoration: InputDecoration(
                      labelText: 'Home Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _homeContactNumberController,
                    decoration: InputDecoration(
                      labelText: 'Home Contact Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  CategoryForm(
                    categories: {
                      'Food Items': [
                        'Rice', 'Sugar', 'Salt', 'Dhal', 'Soya', 'Vegetable oil', 'Coconut milk powder',
                        'Tea powder', 'Biscuits', 'Tin fish', 'Wheat flour', 'Noodles', 'Rice flour',
                        'Spices', 'Milk powder', 'Oats', 'Eggs', 'Yoghurt', 'Bread', 'Butter', 'Jam', 'Nuts'
                      ],
                      'Personal Care Items': [
                        'Toothbrush', 'Toothpaste', 'Pampers', 'Soap', 'Shampoo', 'Combs', 'Face powder', 'Nail cutter'
                      ],
                      'Household Items': [
                        'Bedsheets', 'Pillows', 'Slippers'
                      ],
                      'Hygiene Items': [
                        'Toilet paper', 'Hand sanitizer', 'Tissues', 'Towel', 'Face masks'
                      ],
                      'Medical Items': [
                        'First aid'
                      ]
                    },
                    onSubmit: (selectedCategory, quantities, descriptions, isEmergency) {
                      _submitDonationRequest(selectedCategory, quantities, descriptions, isEmergency);
                    },
                    homeName: _homeNameController.text,
                    homeAddress: _homeAddressController.text,
                    homeContactNumber: _homeContactNumberController.text,
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Future<void> _submitDonationRequest(String selectedCategory, Map<String, int> quantities, Map<String, String> descriptions, bool isEmergency) async {
    final url = 'http://10.3.1.240/donation_app/submit_donation_request.php';
    final data = {
      'category': selectedCategory,
      'quantities': json.encode(quantities),  // Ensure quantities are JSON-encoded
      'descriptions': json.encode(descriptions),  // Ensure descriptions are JSON-encoded
      'isEmergency': isEmergency ? 1 : 0,  // Convert boolean to integer
      'username': widget.username,
      'homeName': _homeNameController.text,
      'homeAddress': _homeAddressController.text,
      'homeContactNumber': _homeContactNumberController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Request submitted successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Navigate to the previous screen
                },
                child: Text('Go Home'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit request: ${jsonResponse['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class CategoryForm extends StatefulWidget {
  final Map<String, List<String>> categories;
  final void Function(String, Map<String, int>, Map<String, String>, bool) onSubmit;
  final String homeName;
  final String homeAddress;
  final String homeContactNumber;

  const CategoryForm({
    Key? key,
    required this.categories,
    required this.onSubmit,
    required this.homeName,
    required this.homeAddress,
    required this.homeContactNumber,
  }) : super(key: key);

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Food Items';
  Map<String, bool> _selectedItems = {};
  bool _isEmergency = false;
  Map<String, int> _quantities = {};
  Map<String, String> _descriptions = {};
  Map<String, bool> _editMode = {};

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  void _initializeItems() {
    _selectedItems = {};
    _quantities = {};
    _descriptions = {};
    _editMode = {};
    widget.categories.forEach((category, items) {
      items.forEach((item) {
        _selectedItems[item] = false;
      });
    });
  }

  void _updateItem(String item, String field, dynamic value) {
    setState(() {
      if (field == 'quantity') {
        _quantities[item] = value;
      } else if (field == 'description') {
        _descriptions[item] = value;
      }
    });
  }

  void _toggleEditMode(String item) {
    setState(() {
      _editMode[item] = !(_editMode[item] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _isEmergency ? Colors.red[50] : Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: widget.categories.keys.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ...widget.categories[_selectedCategory]!.map((item) {
              return CheckboxListTile(
                title: Text(item),
                value: _selectedItems[item],
                onChanged: (bool? value) {
                  setState(() {
                    _selectedItems[item] = value!;
                    if (!value) {
                      _quantities.remove(item);
                      _descriptions.remove(item);
                    }
                  });
                },
              );
            }).toList(),
            SizedBox(height: 16),
            ...widget.categories[_selectedCategory]!.where((item) => _selectedItems[item] == true).map((item) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: _quantities[item]?.toString() ?? '',
                    decoration: InputDecoration(
                      labelText: 'Quantity for $item',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _updateItem(item, 'quantity', int.tryParse(value) ?? 0);
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    initialValue: _descriptions[item] ?? '',
                    decoration: InputDecoration(
                      labelText: 'Description for $item',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _updateItem(item, 'description', value);
                    },
                  ),
                  SizedBox(height: 16),
                ],
              );
            }).toList(),
            CheckboxListTile(
              title: Text('Emergency Request'),
              value: _isEmergency,
              onChanged: (bool? value) {
                setState(() {
                  _isEmergency = value!;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onSubmit(
                    _selectedCategory,
                    _quantities,
                    _descriptions,
                    _isEmergency,
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
