import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home {
  final int id;
  final String name;
  final String address;
  final String contactNumber;
  final String numberOfElders;
  final String district;
  final String email;

  Home({
    required this.id,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.numberOfElders,
    required this.district,
    required this.email,
  });

  factory Home.fromJson(Map<String, dynamic> json) {
    return Home(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      numberOfElders: json['number_of_elders'] ?? '',
      district: json['district'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class HomeService {
  static const String _url = 'http://10.3.1.240/donation_app/fetch_homes.php';

  Future<List<Home>> fetchHomes() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final List<dynamic> homesJson = json.decode(response.body)['homes'];
      return homesJson.map((json) => Home.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load homes');
    }
  }
}

class DonorBrowseElderlyHomesPage extends StatefulWidget {
  @override
  _DonorBrowseElderlyHomesPageState createState() => _DonorBrowseElderlyHomesPageState();
}

class _DonorBrowseElderlyHomesPageState extends State<DonorBrowseElderlyHomesPage> {
  late Future<List<Home>> _homes;

  @override
  void initState() {
    super.initState();
    _homes = HomeService().fetchHomes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Elderly Homes'),
        backgroundColor: Color(0xFF21B2C5),
      ),
      backgroundColor: Color(0xFF21B2C5),
      body: FutureBuilder<List<Home>>(
        future: _homes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No homes found'));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final home = snapshot.data![index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          home.name,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF21B2C5),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Address: ${home.address}',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Contact: ${home.contactNumber}',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Number of Elders: ${home.numberOfElders}',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'District: ${home.district}',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Email: ${home.email}',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
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


