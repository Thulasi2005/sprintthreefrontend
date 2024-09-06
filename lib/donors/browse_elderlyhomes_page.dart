import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class ElderlyHomesPage extends StatefulWidget {
  @override
  _ElderlyHomesPageState createState() => _ElderlyHomesPageState();
}

class _ElderlyHomesPageState extends State<ElderlyHomesPage> {
  List<dynamic> elderlyHomes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchElderlyHomes();
  }

  Future<void> fetchElderlyHomes() async {
    final response = await http.get(Uri.parse('http://10.3.1.240/donation_app/get_elderly_homes.php'));

    if (response.statusCode == 200) {
      setState(() {
        elderlyHomes = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load elderly homes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elderly Homes'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: elderlyHomes.length,
        itemBuilder: (context, index) {
          final home = elderlyHomes[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.home, color: Colors.teal),
              title: Text(home['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text('Address: ${home['address']}'),
                  Text('Contact Number: ${home['contact_number']}'),
                  Text('Number of Elders: ${home['number_of_elders']}'),
                  Text('District: ${home['district']}'),
                  Text('Registration Number: ${home['registration_number']}'),
                ],
              ),
              trailing: Icon(Icons.arrow_forward, color: Colors.teal),
              onTap: () {
                // You can handle item tap here
                showDetailsDialog(home);
              },
            ),
          );
        },
      ),
    );
  }

  void showDetailsDialog(Map<String, dynamic> home) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(home['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Full Name: ${home['full_name']}'),
              Text('NIC: ${home['national_identity_number']}'),
              Text('Role: ${home['role_or_job_title']}'),
              if (home['email'] != null && home['email'].isNotEmpty)
                Text('Email: ${home['email']}'),
            ],
          ),
          actions: [
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
