import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingPage extends StatefulWidget {
  final String donorName;

  BookingPage({required this.donorName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, List<String>> _availableSlots = {};
  bool _loading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots(_selectedDate);
  }

  void _fetchAvailableSlots(DateTime date) async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.3.1.240/donation_App/availableSlots.php?date=${date.toIso8601String().substring(0, 10)}'),
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Response body: $responseBody'); // Debug print

        try {
          final List<dynamic> data = json.decode(responseBody);

          final Map<String, List<String>> slotsMap = {};
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final homeName = item['home_name'] as String?;
              final slot = item['slot'] as String?;
              if (homeName != null && slot != null) {
                if (!slotsMap.containsKey(homeName)) {
                  slotsMap[homeName] = [];
                }
                slotsMap[homeName]!.add(slot);
              }
            }
          }

          setState(() {
            _availableSlots = slotsMap;
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Failed to parse response: $e';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load slots: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _bookSlot(String slot, String homeName) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.3.1.240/donation_App/bookSlot.php'),
        body: {
          'username': widget.donorName,
          'date': _selectedDate.toIso8601String().substring(0, 10),
          'slot': slot,
          'home_name': homeName,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Response body (Booking): $responseBody'); // Debug print

        try {
          final Map<String, dynamic> responseJson = json.decode(responseBody);

          if (responseJson['message'] == 'Booking successful!') {
            setState(() {
              // Update available slots after booking
              _availableSlots[homeName]?.remove(slot);
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Booking successful!'),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(responseJson['message']),
            ));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to parse response: $e'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to book slot: ${response.statusCode}'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDate, selectedDay)) {
      setState(() {
        _selectedDate = selectedDay;
      });
      _fetchAvailableSlots(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Page'),
        backgroundColor: Color(0xFF21B2C5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Hello ${widget.donorName}!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: _onDaySelected,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
            ),
            SizedBox(height: 20),
            Text(
              'Available Slots:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_loading)
              Center(child: CircularProgressIndicator())
            else if (_errorMessage.isNotEmpty)
              Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
            else
              Expanded(
                child: _availableSlots.isNotEmpty
                    ? ListView(
                  children: _availableSlots.entries.map((entry) {
                    final homeName = entry.key;
                    final slots = entry.value;
                    return ExpansionTile(
                      title: Text(homeName),
                      children: slots.map((slot) {
                        return ListTile(
                          title: Text(slot),
                          trailing: ElevatedButton(
                            onPressed: () => _bookSlot(slot, homeName),
                            child: Text('Book'),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                )
                    : Center(child: Text('No available slots for this date')),
              ),
          ],
        ),
      ),
    );
  }
}
