import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonorCalendarResponsePage extends StatefulWidget {
  @override
  _DonorCalendarResponsePageState createState() => _DonorCalendarResponsePageState();
}


class _DonorCalendarResponsePageState extends State<DonorCalendarResponsePage> {
  late Future<List<dynamic>> _bookingsFuture;
  String? donorName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    donorName = ModalRoute.of(context)?.settings.arguments as String?;
    _bookingsFuture = fetchBookings();
  }

  Future<List<dynamic>> fetchBookings() async {
    final response = await http.get(Uri.parse('http://10.3.1.240/donation_app/get_donor_calendar_bookings.php?username=$donorName'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      } else {
        // Handle the error message
        throw Exception('Failed to load bookings: ${data['error']}');
      }
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donor Calendar Response'),
        backgroundColor: Color(0xFF21B2C5),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (donorName != null)
              Text(
                'Welcome, $donorName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            SizedBox(height: 20),
            Text(
              'Here you can manage your calendar and schedule visits with elders.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<dynamic>>(
              future: _bookingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No bookings available');
                } else {
                  final bookings = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return ListTile(
                          title: Text('Time Slot: ${booking['time_slot']}'),
                          subtitle: Text('Status: ${booking['status']}'),
                          tileColor: booking['status'] == 'Confirmed'
                              ? Colors.greenAccent
                              : booking['status'] == 'Cancelled'
                              ? Colors.redAccent
                              : Colors.grey,
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
