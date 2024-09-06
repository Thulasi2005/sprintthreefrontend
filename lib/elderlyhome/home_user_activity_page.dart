import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingManagementPage extends StatefulWidget {
  final int elderlyHomeId;

  BookingManagementPage({required this.elderlyHomeId});

  @override
  _BookingManagementPageState createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> {
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.3.1.240/donation_app/get_bookings.php?elderly_home_id=${widget.elderlyHomeId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched data: $data'); // Log the response

        if (data['success']) {
          setState(() {
            bookings = data['bookings'] ?? []; // Default to empty list if null
            isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load bookings: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch bookings')),
        );
      }
    } catch (e) {
      print('Error fetching bookings: $e'); // Log the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bookings')),
      );
    }
  }

  Future<void> _updateBookingStatus(int bookingId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.3.1.240/donation_app/update_booking.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'booking_id': bookingId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking status updated')),
          );
          _fetchBookings(); // Refresh bookings
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update booking status: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update booking status')),
        );
      }
    } catch (e) {
      print('Error updating booking status: $e'); // Log the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating booking status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bookings'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final bookingId = booking['id'] is int ? booking['id'] : 0; // Ensure bookingId is int
          final timeSlot = booking['time_slot'] as String? ?? ''; // Handle null and default to empty string
          final date = booking['date'] as String? ?? ''; // Handle null and default to empty string
          final status = booking['status'] as String? ?? ''; // Handle null and default to empty string

          return ListTile(
            title: Text('Time Slot: $timeSlot'),
            subtitle: Text('Date: $date'),
            trailing: status == 'pending'
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateBookingStatus(bookingId, 'confirmed');
                  },
                  child: Text('Confirm'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _updateBookingStatus(bookingId, 'declined');
                  },
                  child: Text('Decline'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            )
                : Text(status.toUpperCase()),
          );
        },
      ),
    );
  }
}
