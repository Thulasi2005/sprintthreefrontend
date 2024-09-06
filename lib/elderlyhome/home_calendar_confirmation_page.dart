import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TimeSlotsPage extends StatefulWidget {
  @override
  _TimeSlotsPageState createState() => _TimeSlotsPageState();
}

class _TimeSlotsPageState extends State<TimeSlotsPage> {
  String username = 'Guest';
  List<Map<String, dynamic>> bookedSlots = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null && args.isNotEmpty) {
      setState(() {
        username = args;
      });
      _fetchBookedSlots();
    }
  }

  Future<void> _fetchBookedSlots() async {
    final url = 'http://10.3.1.240/donation_App/fetch_booked_slots.php?home_name=$username'; // Use your local server URL

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response Data: $data'); // Debugging line
        if (data['error'] != null) {
          print('Error: ${data['error']}');
        } else {
          setState(() {
            bookedSlots = List<Map<String, dynamic>>.from(data['slots']);
          });
        }
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error fetching booked slots: $e');
      // Handle error
    }
  }

  Future<void> _confirmBooking(String slot, String date) async {
    final url = 'http://10.3.1.240/donation_App/confirm_booking.php'; // Replace with your PHP script URL
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({
        'home_name': username,
        'slot': slot,
        'date': date,
        'action': 'confirm'
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        print('Booking confirmed');
        _fetchBookedSlots(); // Refresh the list
      } else {
        print('Error confirming booking: ${data['error']}');
      }
    } else {
      print('Failed to confirm booking');
    }
  }

  Future<void> _cancelBooking(String slot, String date) async {
    final url = 'http://10.3.1.240/donation_App/cancel_booking.php'; // Replace with your PHP script URL
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({
        'home_name': username,
        'slot': slot,
        'date': date,
        'action': 'cancel'
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        print('Booking canceled');
        _fetchBookedSlots(); // Refresh the list
      } else {
        print('Error canceling booking: ${data['error']}');
      }
    } else {
      print('Failed to cancel booking');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Time Slot'),
        backgroundColor: Colors.teal[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $username!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView(
                children: bookedSlots.isEmpty
                    ? [Center(child: Text('No available slots'))]
                    : bookedSlots.map((slot) {
                  return _buildTimeSlotCard(
                      context,
                      slot['slot'],
                      slot['date'],
                      slot['donor_username']
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(
      BuildContext context,
      String timeSlot,
      String date,
      String donorUsername
      ) {
    final isBooked = bookedSlots.any((slot) =>
    slot['slot'] == timeSlot && slot['date'] == date);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.teal[900]!, width: 2),
      ),
      child: ListTile(
        title: Text(
          '$timeSlot on $date',
          style: TextStyle(
            color: Colors.teal[900],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: isBooked
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _cancelBooking(timeSlot, date),
            ),
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: () => _confirmBooking(timeSlot, date),
            ),
          ],
        )
            : Icon(Icons.arrow_forward_ios, color: Colors.teal[900]),
        onTap: () {
          if (!isBooked) {
            // Handle time slot selection
            // You can navigate to the next page with this time slot selected
          }
        },
      ),
    );
  }
}
